#!/bin/bash
##
# Color  Variables
##
RESTORE=$(echo -en '\001\033[0m\002')
RED=$(echo -en '\001\033[00;31m\002')
GREEN=$(echo -en '\001\033[00;32m\002')
YELLOW=$(echo -en '\001\033[00;33m\002')
BLUE=$(echo -en '\001\033[00;34m\002')
MAGENTA=$(echo -en '\001\033[00;35m\002')
PURPLE=$(echo -en '\001\033[00;35m\002')
CYAN=$(echo -en '\001\033[00;36m\002')
LIGHTGRAY=$(echo -en '\001\033[00;37m\002')
LRED=$(echo -en '\001\033[01;31m\002')
LGREEN=$(echo -en '\001\033[01;32m\002')
LYELLOW=$(echo -en '\001\033[01;33m\002')
LBLUE=$(echo -en '\001\033[01;34m\002')
LMAGENTA=$(echo -en '\001\033[01;35m\002')
LPURPLE=$(echo -en '\001\033[01;35m\002')
LCYAN=$(echo -en '\001\033[01;36m\002')
WHITE=$(echo -en '\001\033[01;37m\002')

##
# BASH menu script that database setup:
#   - Backup Database
#   - Restore Database
#   - Truncate Database
##
DB_HOST=127.0.0.1
DB_PORT=3306

function backup_database() {
    echo ""
    echo "${CYAN}Backup database on ${DB_HOST}:${DB_PORT}:${RESTORE} "
    read -r -p "Database username: " DB_USERNAME
    # Disable echo
    stty -echo
    read -r -s -p "Database password: " DB_PASSWORD
    # Turn echo back on
    stty echo
    printf "\n"
    read -r -p "Database name: " DB_NAME
    until mysql -u"$DB_USERNAME" -p"$DB_PASSWORD" -h"$DB_HOST" -P"$DB_PORT" -e ";"; do
        # Disable echo
        stty -echo
        read -r -s -p "Can't connect, please retry: " DB_PASSWORD
        # Turn echo back on
        stty echo
        printf "\n"
    done
    if [ ! -d "/tmp/backup" ]; then
        mkdir /tmp/backup
    fi
    mysqldump --user="$DB_USERNAME" --password="$DB_PASSWORD" --host="$DB_HOST" --port="$DB_PORT" \
        --max-allowed-packet=1024M --single-transaction --lock-tables --set-gtid-purged=OFF --no-data \
        "$T" | gzip -c >"/tmp/backup/$DB_NAME-$T.sql.gz"
    echo "${GREEN}Database $DB_NAME backup created successfully${RESTORE}"
    echo ""
}
function restore_database() {
    echo ""
    echo "${CYAN}Restore database on ${DB_HOST}:${DB_PORT}:${RESTORE} "
    read -r -p "Database username: " DB_USERNAME
    # Disable echo
    stty -echo
    read -r -s -p "Database password: " DB_PASSWORD
    # Turn echo back on
    stty echo
    printf "\n"
    read -r -p "Database name: " DB_NAME
    until mysql -u"$DB_USERNAME" -p"$DB_PASSWORD" -h"$DB_HOST" -P"$DB_PORT" -e ";"; do
        # Disable echo
        stty -echo
        read -r -s -p "Can't connect, please retry: " DB_PASSWORD
        # Turn echo back on
        stty echo
        printf "\n"
    done
    for T in $(mysql --user="$DB_USERNAME" --password="$DB_PASSWORD" --host="$DB_HOST" --port="$DB_PORT" -N -B -e "SHOW TABLES FROM $DB_NAME"); do
        num=$((i++))
        echo "Restore data table $num: $DB_NAME.$T"
        mysql --max_allowed_packet=1024M --default-character-set=utf8 --binary-mode=1 --user=$DB_USERNAME --password=$DB_PASSWORD --host=$DB_HOST --port=$DB_PORT $DB_NAME <"/tmp/backup/pm-tables/$T.sql"
    done
    echo "${GREEN}Database $DB_NAME restored successfully${RESTORE}"
    echo ""
}
function trucate_database() {
    echo ""
    echo "${CYAN}Cleaning database on ${DB_HOST}:${DB_PORT}:${RESTORE} "
    read -r -p "Database username: " DB_USERNAME
    # Disable echo
    stty -echo
    read -r -s -p "Database password: " DB_PASSWORD
    # Turn echo back on
    stty echo
    printf "\n"
    read -r -p "Database name: " DB_NAME
    until mysql -u"$DB_USERNAME" -p"$DB_PASSWORD" -h"$DB_HOST" -P"$DB_PORT" -e ";"; do
        # Disable echo
        stty -echo
        read -r -s -p "Can't connect, please retry: " DB_PASSWORD
        # Turn echo back on
        stty echo
        printf "\n"
    done
    echo "Mysql host $DB_HOST, port $DB_PORT, cleaning data table $num: $DB_NAME.$T"
    mysql --user="$DB_USERNAME" --password="$DB_PASSWORD" --host="$DB_HOST" --port="$DB_PORT" -N -B -e "TRUNCATE TABLE $DB_NAME.$T"
    echo "${GREEN}Database $DB_NAME backup created successfully${RESTORE}"
    echo ""
}

# Function to display menu
menu() {
    echo -ne "
Actions menu for setup database:
${GREEN}1)${RESTORE} Backup Database
${GREEN}2)${RESTORE} Restore Database
${GREEN}3)${RESTORE} Truncate Database
${GREEN}0)${RESTORE} Exit
${BLUE}Choose an option:${RESTORE} "
    read -r a
    case $a in
    1)
        backup_database
        menu
        ;;
    2)
        restore_database
        menu
        ;;
    3)
        trucate_database
        menu
        ;;
    0) exit 0 ;;
    *)
        echo -e "$(ColorRed 'Wrong option.')"
        menu
        ;;
    esac
}

# Call the menu function
menu
