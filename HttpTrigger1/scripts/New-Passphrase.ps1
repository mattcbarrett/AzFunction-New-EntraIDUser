<#
  .Synopsis
  Generates a 4-word passphrase.

  .Description
  Generates a 4-word passhhrase based on the EFF Diceware short wordlist. Each word is capitalized to increase readabilty.

  .Example
  # Generate a new passphrase.
  New-Passphrase
#>

function New-Passphrase {
  # Load wordlist from file.
  $wordlist = Get-Content -Path $PSScriptRoot\eff_short_wordlist.txt

  # Initialize a new variable to hold the passphrase
  $passphrase = $null

  # Loop 4 times, so we have 4 words in the passphrase
  while ($val -le 3) {

    # Increment the counter
    $val++

    # Choose a random number between 1 and the length of the wordlist, retrieve that line from the file, and select the word
    $number = Get-Random -Minimum 1 -Maximum $wordlist.Length
    $entry = ($wordlist[$number]) -split "	"

    # Capitalize the first letter
    $firstLetter = $entry[1].Substring(0, 1).ToUpper()
    $remainder = $entry[1].Substring(1)
    $word = $firstLetter + $remainder
    
    # Append the word to the string variable
    $passphrase += $word
  }

  # Return the passphrase
  return $passphrase + $entry[0].Substring(0, 1)
}