/**
* Function checks the validity of the customer number
* @param    {string}    number      Customer number
* @returns  {boolean}               Flag for a validity of the provided number
*/
const validateNumberFormat = (number) => {
    // The RegEx expression to match a valid phone number (minim um of 10 digits)
    const validScheme = /^\+1?(\d{10,15})$/
    return validScheme.test(number)
}

module.exports = {
    validateNumberFormat
}