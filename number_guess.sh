#! /bin/bash


# Connection settings
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


####################   INPUT FLAGGER   ####################
# If needed to understand if username is passed as script argument
if [[ -z $1 ]]
then
  # No argument as username input
  echo "Enter your username:"
  read USERNAME_INPUT
else
  # Argument as username input
  USERNAME_INPUT=$1
fi

# Don't care how the input is made, but now is called USERNAME_INPUT
USERNAME_RESULT=$($PSQL "SELECT username FROM game_data WHERE username = '$USERNAME_INPUT'")


####################   INPUT DATABASE CHECKER   ####################
# Check if the username already exists in the database
if [[ -z $USERNAME_RESULT ]]
then
  # Username not found
  NEW_USER=true

  echo "Welcome, $USERNAME_INPUT! It looks like this is your first time here."
else
  # Username found
  NEW_USER=false

  GAMES_PLAYED_RESULT=$($PSQL "SELECT games_played FROM game_data WHERE username = '$USERNAME_INPUT'")
  BEST_GAME_RESULT=$($PSQL "SELECT best_game FROM game_data WHERE username = '$USERNAME_INPUT'")
  echo "Welcome back, $USERNAME_RESULT! You have played $GAMES_PLAYED_RESULT games, and your best game took $BEST_GAME_RESULT guesses."
fi


####################   GUESSING GAME ALGO   ####################
# Random number generated for the while loop. Loop will terminate when user will give the correct answer
INPUT=""
INPUT_COUNTER=0
RANDOM_NUMBER=$((1 + RANDOM % 1000))
#echo $RANDOM_NUMBER

while [[ $INPUT != $RANDOM_NUMBER ]]
do
  echo "Guess the secret number between 1 and 1000:"
  read INPUT

  # Case to filter integer input
  case $INPUT in
      ''|*[!0-9]*)
          echo "That is not an integer, guess again:"
          ;;
      *)
          ((INPUT_COUNTER++))
          if [[ $INPUT == $RANDOM_NUMBER ]]
            then
            # If input is the correct number
            echo "You guessed it in $INPUT_COUNTER tries. The secret number was $RANDOM_NUMBER. Nice job!"
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
          ;;
  esac
done


####################   GUESSING GAME ALGO   ####################
if $NEW_USER
then
  # New user registration
  GAMES_PLAYED_RESULT=1
  BEST_GAME_RESULT=$INPUT_COUNTER
  REGISTRATION_RESULT=$($PSQL "INSERT INTO game_data(username, games_played, best_game) VALUES('$USERNAME_INPUT', $GAMES_PLAYED_RESULT, $BEST_GAME_RESULT)")
else
  # Increment of games played of old players
  ((GAMES_PLAYED_RESULT++))
  # Old user data update if needed
  if [[ $INPUT_COUNTER < $BEST_GAME_RESULT ]]
  then
    # If old user did a better score
    BEST_GAME_RESULT=$INPUT_COUNTER
    UPDATE_RESULT=$($PSQL "UPDATE game_data SET games_played = $GAMES_PLAYED_RESULT, best_game = $BEST_GAME_RESULT WHERE username = '$USERNAME_RESULT'")
  else
    # If old user did a equal or worse score
    UPDATE_RESULT=$($PSQL "UPDATE game_data SET games_played = $GAMES_PLAYED_RESULT WHERE username = '$USERNAME_RESULT'")
  fi
fi
