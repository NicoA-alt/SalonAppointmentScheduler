#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?"

MAKE_APPOINTMENT () {
if [[ $1 ]]
then
  echo -e "\n$1"
fi
SERVICES=$($PSQL "select service_id,name from services order by service_id")
echo "$SERVICES" | while read SERVICE_ID BAR NAME
do
  echo "$SERVICE_ID) $NAME" 
done
read SERVICE_ID_SELECTED
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
  MAKE_APPOINTMENT "I could not find that service. What would you like today?"
else 
  RESULT_SERVICE_ID=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED ")  
  if [[ -z $RESULT_SERVICE_ID ]]
  then 
    MAKE_APPOINTMENT "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER=$($PSQL "insert into customers(phone,name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")    
    fi
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
    echo -e "\nWhat time would you like your cut,$CUSTOMER_NAME?"
    read SERVICE_TIME
    #if [[ $SERVICE_TIME =~ ^[01]?[0-9]|2[0-3]:[0-5][0-9]$ ]] HACIA FALLAR EL TEST
    INSERT_APPOINTMENT=$($PSQL "insert into appointments(customer_id,service_id,time) values('$CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")
    if [[ $INSERT_APPOINTMENT = 'INSERT 0 1' ]]
    then
      SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
      echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
fi
}
MAKE_APPOINTMENT