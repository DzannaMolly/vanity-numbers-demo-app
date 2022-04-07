const words = require('an-array-of-english-words')
const { getDynamoDBItems, insertDynamoDBItems } = require('./dynamodb.js')
const { dialPadPermutations } = require('./helpers.js')
const { validateNumberFormat } = require('./validator.js')

// An array to store all of the character permutations from the dial pad
let permutationsResult = []

/**
* Lambda handler
* @param    {Object} event
* @param    {Object} context
* @param    {Object} callback
*/
exports.handler = async (event, context, callback) => {
    try {
        // How many digits will be considered for the vanity numbers
        const vanityLimit = process.env.VANITY_CHARS ? parseInt(process.env.VANITY_CHARS) : 4

        // How many vanity numbers will be considered
        const topElements = process.env.VANITY_NUMBERS_LIMIT ? parseInt(process.env.VANITY_NUMBERS_LIMIT) : 5

        // An array for the best 5 vanity numbers
        let finalResult = []

        // Extracting the customer number from the AWS Connect event object
        const number = event['Details']['ContactData']['CustomerEndpoint']['Address']

        if (!number) {
            throw new Error('Invalid input data')
        }

        // Validate the customer number format
        const validNumber = validateNumberFormat(number)

        if (!validNumber) {
            throw new Error('Invalid phone number format')
        }
        
        // Retrieve existing vanity numbers for the customer (if any) from DynamoDB
        const vanityNumbers = await getDynamoDBItems(number)

        if (!vanityNumbers) {
            // Filter the words whose length is less than or equal to the limit to reduce the array size, and sort
            const filteredWords = words.filter(word => word.length <= vanityLimit).sort()

            // Divide the number in two and use the second sequence of digits for generating random words
            const firstDigits = number.slice(0, number.length - vanityLimit)
            const lastDigitsArray = number.slice(-vanityLimit).split('')

            // Calculate all of the character permutations from the dial pad for the input digits
            dialPadPermutations(lastDigitsArray, lastDigitsArray.length, 0, [], permutationsResult)

            // Iterate over the resulted array and put any obtained meaningful words into the result array
            for (let i = 0; i < permutationsResult.length; i++) {
                if (filteredWords.includes(permutationsResult[i].toLowerCase())) {
                    finalResult.push(permutationsResult[i])
                    // Remove the word that is already in the result array to prevent duplicates 
                    permutationsResult.splice(permutationsResult.indexOf(permutationsResult[i]), 1)
                }
            }

            // Extend the result array with random character combinations in case it has fewer elements
            if (finalResult.length < topElements) {
                finalResult = finalResult.concat(permutationsResult.slice(0, topElements - finalResult.length))
            }
            if (finalResult.length >= 3) {
                console.log('Insert vanity numbers into DynamoDB table')

                // An array for the vanity numbers formatted for storing in DynamoDB
                const dynamoDBItems = []

                // Format the vanity numbers for storing in DynamoDB
                for (let i = 0; i < finalResult.length; i++) {
                    finalResult[i] = firstDigits + finalResult[i]
                    dynamoDBItems.push({'S': finalResult[i]})
                }

                // Store the vanity numbers and the customer number in DynamoDB
                await insertDynamoDBItems(number, dynamoDBItems)
            }
        } else {
            // Iterate over the result object store the vanity numbers in the array
           for (let i = 0; i < vanityNumbers['vanity-numbers']['L'].length; i++) {
               finalResult.push(vanityNumbers['vanity-numbers']['L'][i]['S'])
           }
        }

        // The callback function with the result object (first three vanity numbers) passed to the AWS Connect ContactFlow
        callback(null, {
            FirstNumber: finalResult[0],
            SecondNumber: finalResult[1],
            ThirdNumber: finalResult[2]
        })

        return true
    } catch (error) {
        // Log the error in CloudWatch
        console.log(error)

        // The callback function with the error object passed to the AWS Connect ContactFlow
        callback(error)
    }
}