#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# Clear the tables before inserting new data
echo $($PSQL "TRUNCATE games, teams RESTART IDENTITY")

# Read the CSV file and insert data
cat games.csv | while IFS=',' read year round winner opponent winner_goals opponent_goals
do
  if [[ $year != "year" ]]
  then
    # Insert teams into teams table
    # Check if winner exists
    WINNER_ID=$($PSQL "SELECT teamid FROM teams WHERE name='$winner'")
    if [[ -z $WINNER_ID ]]
    then
      # insert winner
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$winner')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then 
        echo "Inserted into teams: $winner"
      fi
      # Get new winner id
      WINNER_ID=$($PSQL "SELECT teamid FROM teams WHERE name='$winner'")
    fi

    # Check if opponent exists
    OPPONENT_ID=$($PSQL "SELECT teamid FROM teams WHERE name='$opponent'")
    if [[ -z $OPPONENT_ID ]]
    then
      # insert opponent
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$opponent')")
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
      then 
        echo "Inserted into teams: $opponent"
      fi
      # Get new opponent id
      OPPONENT_ID=$($PSQL "SELECT teamid FROM teams WHERE name='$opponent'")
    fi

    # Insert game into games table
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES($year, '$round', $winner_goals, $opponent_goals, $WINNER_ID, $OPPONENT_ID)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into games: $year $round $winner vs $opponent"
    fi
  fi
done