#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

ESCAPED_USERNAME=${USERNAME//\'/\'\'}

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$ESCAPED_USERNAME'")

if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."

  USER_ID=$($PSQL "INSERT INTO users(username) VALUES('$ESCAPED_USERNAME') RETURNING user_id" | head -n 1)
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=0

echo "Guess the secret number between 1 and 1000:"

while true
do
  if ! IFS= read -r GUESS
  then
    exit 0
  fi

  NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))

  if [[ ! $GUESS =~ ^-?[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  GUESS_NUMBER=$((10#$GUESS))

  if (( GUESS_NUMBER > SECRET_NUMBER ))
  then
    echo "It's lower than that, guess again:"
  elif (( GUESS_NUMBER < SECRET_NUMBER ))
  then
    echo "It's higher than that, guess again:"
  else
    $PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)" > /dev/null

    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
done
# Game entry point
# PostgreSQL stores game statistics
# Guess validation is handled in the game loop
# Game results are saved after a correct guess
