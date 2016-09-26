AMERICAN_EXPRESS = 'American Express'
MASTERCARD = 'Mastercard'
VISA = 'Visa'
DISCOVER = 'Discover'

CARD_TYPES = [
  [AMERICAN_EXPRESS, AMERICAN_EXPRESS],
  [MASTERCARD, MASTERCARD],
  [VISA, VISA],
  [DISCOVER, DISCOVER]
]

CARD_TYPE_NUMBER_FORMAT = {
  AMERICAN_EXPRESS => {
    length: 15,
    format: ['34', '37'],
    cvv_length: 4
  },
  MASTERCARD => {
    min_length: 16,
    max_length: 19,
    format: ['51', '52', '53', '54', '55'],
    cvv_length: 3
  },
  VISA => {
    min_length: 13,
    max_length: 16,
    format: ['4'],
    cvv_length: 3
  },
  DISCOVER => {
    length: 16,
    format: ['6011', '65'],
    format_range: [{
        from: '622126',
        to: '622925'
      },
      {
        from: '644',
        to: '649'
      }
    ],
    cvv_length: 3
  }
}