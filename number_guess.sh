#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

# Get username from user
echo "Enter your username:"
read USERNAME

# Try and get user information from the database
USER=$($PSQL "SELECT * FROM users WHERE username='$USERNAME';")
if [[ -z $USER ]]
then
  # Not played
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$USERNAME', 0, NULL);")
else
  # Played before
  read USER_ID BAR USERNAME BAR GAMES_PLAYED BAR BEST_GAME <<< $USER
  echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
fi

# Generate a random number
RANDOM_NUMBER=$((RANDOM % 1000 + 1))

# Initialise the guesses taken
GUESSES=0

# Prompt and initial guess
echo -e "\nGuess the secret number between 1 and 1000:"
read GUESSED_NUMBER
((GUESSES++))
while [[ $GUESSED_NUMBER != $RANDOM_NUMBER ]] 
do
  # Checks if the input is not a number
  if [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]]
  then
    echo -e "That is not an integer, guess again:"
    read GUESSED_NUMBER
  # Is higher than the random number
  elif [[ $GUESSED_NUMBER > $RANDOM_NUMBER ]]
  then
    echo -e "\nIt's lower than that, guess again:"
    read GUESSED_NUMBER
    ((GUESSES++))
  # Is lower than the random number
  elif [[ $GUESSED_NUMBER < $RANDOM_NUMBER ]]
  then
    echo -e "\nIt's higher than that, guess again:"
    read GUESSED_NUMBER
    ((GUESSES++))
  fi
done

# Prompts the user for a correct guess
echo -e "\nYou guessed it in $GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"

# Reads the users previous details from the database
USER=$($PSQL "SELECT * FROM users WHERE username='$USERNAME';")
read USER_ID BAR USERNAME BAR GAMES_PLAYED BAR BEST_GAME <<< $USER

# Check if the current guess count is less than the best game
if [[ $GUESSES -lt $BEST_GAME || $BEST_GAME -eq NULL ]]; then
    BEST_GAME=$GUESSES
fi

# Increment the games played
((GAMES_PLAYED++))

# Update the users deatils in the database
UPDATE_USER=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE user_id=$USER_ID;")