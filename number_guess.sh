#! /bin/bash


# Connection settings
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


GUESSING_GAME()
{
  # Random number generated for the while loop. Loop will terminate when user will give the correct answer
  INPUT=""
  INPUT_COUNTER=0
  RANDOM_NUMBER=$((1 + RANDOM % 1000))
  echo $RANDOM_NUMBER

  while [[ $INPUT != $RANDOM_NUMBER ]]
  do
    echo "Guess the secret number between 1 and 1000:"
    read INPUT
    ((INPUT_COUNTER++))

    if [[ $INPUT == $RANDOM_NUMBER ]]
    then
      # If input is the correct number
      echo "You guessed it in $INPUT_COUNTER tries. The secret number was $RANDOM_NUMBER. Nice job!"

      # Logic to store best game result in database
      if [[ $GAMES_PLAYED_RESULT == 1 ]]
      then
        # New user will have only 1 best game (the current)
        BEST_GAME_RESULT=$INPUT_COUNTER
        REGISTRATION
      
      else
        # Comparing previous score with new one
        if [[ $INPUT_COUNTER < $GAMES_PLAYED_RESULT ]]
        then
          # Actual score is better than previous one
          BEST_GAME_RESULT=$INPUT_COUNTER
          REGISTRATION
        fi
      fi

      else
        if [[ $INPUT > $RANDOM_NUMBER ]]
        then
          # If input is bigger than correct number
          echo "It's lower than that, guess again:"
        else
          # If input is smaller than correct number
          echo "It's higher than that, guess again:"
        fi
      fi
  done
}


REGISTRATION()
{
  # Store game stats in database
  REGISTRATION_RESULT=$($PSQL "INSERT INTO game_data(username, games_played, best_game) VALUES('$USERNAME_RESULT', $GAMES_PLAYED_RESULT, $BEST_GAME_RESULT)")
}


# Check if script is receiving a username as input
if [[ -z $1 ]]
then
  # No input 
  echo "Please, insert a username in input!"
else
  USERNAME_RESULT=$($PSQL "SELECT username FROM game_data WHERE username = '$1'")

  # Check if the username exists in database
  if [[ -z $USERNAME_RESULT ]]
  then
    # Username not found 
    echo "Welcome, $1! It looks like this is your first time here."
    USERNAME_RESULT=$1
    GAMES_PLAYED_RESULT=1
  else
    # Username found
    GAMES_PLAYED_RESULT=$(($PSQL "SELECT games_played FROM game_data WHERE username = $1") + 1)
    BEST_GAME_RESULT=$($PSQL "SELECT best_game FROM game_data WHERE username = $1")
    echo "Welcome back, '$USERNAME_RESULT'! You have player $GAMES_PLAYED_RESULT, and your best game took $BEST_GAME_RESULT guesses."
  fi

  GUESSING_GAME
fi
