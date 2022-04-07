// Phone dial pad
const dialPad = ['0', '1', 'ABC', 'DEF', 'GHI', 'JKL', 'MNO', 'PQRS', 'TUV', 'WXYZ']

/**
* Function that calculates all of the permutations from the dial pad characters for a given input digits
* @param    {string[]}  input           An array with the dialed digits
* @param    {number}    inputLength     The length of the dialed digits array
* @param    {number}    iterator        An incremental length parameter
* @param    {string[]}  output          Temporary array with permutations
* @param    {string[]}  permutations    The global variable used in the Lambda that stores the final permutations
* @returns  {string[]}  result          The result array with all of the permutations
*/
const dialPadPermutations = (input, inputLength, iterator, output, permutations) => {
    if (iterator === inputLength) {
        permutations.push(output.join(''))
    } else {
        // Loop through the dial pad characters and calculate recursively all of the permutations
        for (let i = 0; i < dialPad[input[iterator]].length; i++) {
            output[iterator] = dialPad[input[iterator]][i]
            dialPadPermutations(input, inputLength, iterator + 1, output, permutations)
        }
    }

    return permutations
}

module.exports = {
    dialPadPermutations
}