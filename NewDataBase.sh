#!/bin/bash
PS3="==>  "

function CreateDatabase {
    #clear
    echo "Enter database name"
    read db
    
    #checking not entered a null 
    if [ "$db" != "" ]
    then
        # find if we have the same name of the entered database or not
            findRes=`find -name $db 2>>/dev/null`

        if [ "./$db" = "$findRes" ]
        then echo "this database already exists "
        else
        mkdir $db
        echo " database is created successfully, your new database is" $db
        fi
    else echo "Enter a proper name for the database"
    fi


}

function ListDatabase {
    # ls for listing files/directoreis
    # -A : almost all for ignoring . and ..
    # -l : long listing
    # grep only directories (listed files begin with d)
    # wc -l : count output lines of grep


    dbls=`ls -Al | grep ^d | wc -l`
    
        # check if this count is zero so no databses found   
            
        if [ $dbls -eq 0 ]
            then 
                echo "No Databases found"
        else
      # list only directories in case there are files exist in the DBMS
            ls -d */
        fi
    }


    function CreateTable {
    #clear
        echo "Enter the table name"
        read t
            # check if the input value exists or null
            if [ "$t" != "" ]
        then
        # flags for validation
            tisExist=0
            tnotValid=0

        # array carries all tables in database
        # listing only tables (files) inside array
            createT_arr=(`ls -Al | grep ^-`)
        # looping on array elements to check if there is a table exists with the same name
            for i in $(seq 1 ${#createT_arr[@]})
            do  
                if [ "${createT_arr[i-1]}" = "$t" ]
                then 
                    echo "This table name already exists"
                    tisExist=1
                fi
            done

            if [ $tisExist -ne 1 ]
            then
                echo "Enter the number of columns:"
                read no_cols
            # check if the input has value and is a number 
                if [[ "$no_cols" != "" && $no_cols =~ ^[0-9]+$ ]]
                
                
           # define our fields/columns separator
                then
                    fieldSep="|"

                    for i in $(seq $no_cols)
                    do  
 # check if the we are looping on the first column to assign it as a primary key
                        if [ $i -eq 1 ]
                        then 
                            echo "Enter the name of Primary Key (column $i):"
                            read fieldN

                            # check if input has value 
                            if [ "$fieldN" != "" ]
                            then
                                # concatenate the first field with the separator
                                header=$fieldN$fieldSep
                            else 
                                tnotValid=1
                                break
                            fi

                        else
                            echo "Enter the name of column number $i:"
                            read fieldN


                            # check if input has value 
                            if [ "$fieldN" != "" ]
                            then
                                # check if the loop is the last one to prevent the concatenation of separator
                                if [ $i -eq $no_cols ]
                                then
                                    header=$header$fieldN
                                else
                                    header=$header$fieldN$fieldSep
                                fi
                            else 
                                tnotValid=1
                                break
                            fi
                        fi
                    done

                    # if we get valid inputs so create table
                    if [ $tnotValid -ne 1 ]
                    then
                        touch $t
                        echo $header >> $t
                        echo "$t table is created successfully"
                    
                        # assign empty value to header variable to hold the new table meta-data
                        header="" 
                    else
                        echo "Columns' names can't be null values"
                    fi
                else 
                    echo "Enter a proper number of columns"
                fi
            fi
        else
            echo "Please enter a proper name for the table"
        fi

}

function listTables {
        #ls -a ./$udb
        listing=`ls -Al | grep ^- | wc -l`
        
        if [ $listing -eq 0 ]
            then echo -e "No tables found \n Press 1 to Create table"
            
        else ls -p | grep -v /
        fi

}

function DropTable {
    #clear
        echo -e "Your current tables are : \n "
        listTables
        echo "Choose the table name you want to drop ^^: "
        read dt
        # rm -R ./$udb/$dt
        # echo " Droped" $dt

        isExistdrop=0

        dropT_arr=(`ls -Al | grep ^-`)
        
        for i in $(seq ${#dropT_arr[@]})
        do  
            if [ "${dropT_arr[i-1]}" = "$dt" ]
            then
                isExistdrop=1
            fi
        done

        if [ $isExistdrop -eq 1 ]
        then
            rm $dt 
            echo -e "$dt table is dropped successfully\nClick Enter to back to CONNECT MENU "
        else
            echo -e "This table doesn't exist ,Click Enter to back to CONNECT MENU  "

            #DropTable
            
        fi
        
}

function InsertIntoTable {
    #clear
        echo -e "Your current tables are: \n "
        listTables 
        echo -e "please choose the table you want to insert into: \n "
        read TableName

        # flags for validation
        isExisted_insert=0
        notValidInsertion=0

        InsertT_arr=(`ls -Al | grep ^-`)

        for i in $(seq 1 ${#InsertT_arr[@]})
        do  
            if [ "${InsertT_arr[i-1]}" = "$TableName" ]
            then 
                isExisted_insert=1
            fi
        done

        if [ $isExisted_insert -eq 1 ]
        then
            columnsNo=$(awk 'BEGIN{FS="|"}{
                if(NR == 1)
                print NF
            }' $TableName)
            #no. of rec == first line then print no. of fields how many columns  
            
            fieldSep="|"

            for i in $(seq $columnsNo)
            do  
                fieldName=$(awk 'BEGIN{FS="|"}{if(NR == 1) print $'$i'}' $TableName)

                if [ $i -eq 1 ]
                then
                    echo "Enter the value of $fieldName field:"
                    read field
                    pK=$field
                    
                    if [ "$pK" != "" ]
                    then

                        if [ "$pK" = "`awk -F "|" '{NF=1; print $'$i'}' $TableName | grep "\b$pK\b"`" ]
                        then
                            echo "This Primary key already exists,It has to be not repeated 'unique '"
                            notValidInsertion=1
                            break
                        else
                            record=$field$fieldSep
                            continue
                        fi
                    else
                        echo "The primary key can't be null"
                        notValidInsertion=1
                        break
                    fi
                else
                    echo "Enter the value of $fieldName field:"
                    read field
                fi
                # check if the loop is the last one to prevent the concatenation of separator
                if [ $i -eq $columnsNo ]
                then
                    record=$record$field
                else
                    record=$record$field$fieldSep  
                fi 
            done

            if [ $notValidInsertion -ne 1 ]
            then
                echo $record >> $TableName 
                echo "Insertion Done"

                #assign empty value to record variable to hold the new insertion
                record="" 
            else
                echo "Insertion Error"
            fi
        else
            echo -e  "This table doesn't exist\n please choose again"

            InsertIntoTable
        fi
    }

    function SelectFromTable {
    #clear
        echo -e "these are your tables: \t"
        listTables
        echo "Enter the table name you want to select from:"
        read TableName
        isExisted_select=0
        selectT_arr=(`ls -Al | grep ^-`)
            for i in $(seq 1 ${#selectT_arr[@]})
        do  
            if [ "${selectT_arr[i-1]}" = "$TableName" ]
            then 
                isExisted_select=1
            fi
            
        done

        if [ $isExisted_select -eq 1 ]
        then
            echo "Choose whether select all or using the table's primary key"
            select choice in "All" "Using PK" "Back to Connect Menu"
            do    
            case $choice in
                "All" ) sed '/*/p' $TableName ;;
                "Using PK" ) echo "Enter the Primary Key value to select your record"
                            read pk_value
                              # another way to check if the input is null or has value if
                            
                            if [ ! -z $pk_value ] 
                            then
                            
                            # check if the inserted primary key exists in our table by :
                            # 1) getting the first column of table (pk) using awk ($1) 
                            # 2) grep on the output of awk to find if this pk exists
                            # 3) adding \b as borders to match the exact inserted pk
                            
                                if [ "$pk_value" = "`awk -F "|" '{NF=1; print $1}' $TableName | grep "\b$pk_value\b"`" ]
                                then
                                # get the record number using awk 
                                    NR=`awk 'BEGIN{FS="|"}{if ($1=="'$pk_value'") print NR}' $TableName`
                                                                    # get the table meta-data (header)
                                    echo `awk 'BEGIN{FS="|"}{if (NR==1) print $0}' $TableName`
                                       
                                # print the record selected using sed
                                # -n : prevent the default of sed command to avoid unwanted records and duplication
                                    sed -n ""$NR"p" $TableName

                                else
                                    echo "This Primary key doesn't exist"
                                fi
                            else
                                echo "The primary key can't be null"
                            fi    
                ;;
                "Back to Connect Menu" )
                ConnectMenu
                    ;;
                * ) echo $REPLY is not found , enter the choice from the Connect Menu  ;;
            esac
            done
        else
                echo -e  "This table doesn't exist\n please choose again"

        fi
}

function DeleteFromTable {
    #clear
        echo -e "Your current tables are: \n "
        listTables 
        echo "Enter the table name you want to delete from:"
        read TableName

        # flag for validation
        isExisted_delete=0  
    # array carries all tables in database
    # listing only tables (files) inside array
        deleteT_arr=(`ls -Al | grep ^-`)
    # looping on array elements to check if there is a table exists with the input name
        for i in $(seq 1 ${#deleteT_arr[@]})
        do  
            if [ "${deleteT_arr[i-1]}" = "$TableName" ]
            then 
                isExisted_delete=1
            fi
        done

        if [ $isExisted_delete -eq 1 ]
        then
            echo "Enter the primary key value of the record you want to delete:"
            read pK

            # check if the input is null or has value 
            if [ ! -z $pK ]
            then
            
            # check if the inserted primary key exists in our table by :
            # 1) getting the first column of table (pk) using awk ($1) 
            # 2) grep on the output of awk to find if this pk exists
            # 3) adding \b as borders to match the exact inserted pk   
            
            
            
            if [ "$pK" = "`awk -F "|" '{NF=1; print $1}' $TableName | grep "\b$pK\b"`" ]
                then
                    
                    # get the record number using awk 
                    NR=`awk 'BEGIN{FS="|"}{if ($1=="'$pK'") print NR}' $TableName`
                    
                    # delete the selected record using sed
                    # -i : to edit files in place 
                    sed -i ''$NR'd' $TableName
                    
                    echo "Record deleted successfully"
                else
                    echo -e "This Primary key doesn't exist,\n Click Enter to back to CONNECT MENU "
                     
                    
                fi
            else
                echo -e "The primary key can't be null, \n Click Enter to back to CONNECT MENU"
            fi    
        else
            echo -e "This table doesn't exist, \n Click Enter to back to CONNECT MENU"
        fi
}

function ConnectMenu {
    #clear
        echo "Successfully connected to $DatabaseConnect database"
        echo "Connect Menu:"
        select choice in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Go to Main Menu"
        do    
        case $choice in
            "Create Table" ) CreateTable ;;
            "List Tables" ) listTables ;;
            "Drop Table" ) DropTable ;;
            "Insert into Table" ) InsertIntoTable;;
            "Select From Table" ) SelectFromTable ;;
            "Delete From Table" ) DeleteFromTable ;;
            # to go back to previous menu (disconnect from the current database): change directory backward one step
            "Go to Main Menu" ) cd .. ; MainMenu ;;
            * ) echo $REPLY is not one of the choices ;;
        esac
        done
}

function ConnectDatabase {
    #clear
    echo -e "These are your databases ^^ \t  "
    ListDatabase  
    echo "Choose the database you want to connect with ^^ "
    read udb 
    findUdb=`find -name $udb 2>>/dev/null`

        if [ "./$udb" = "$findUdb" ] 
            then 
                cd $udb
                ConnectMenu
        else
            echo -e "\nThis database doesn't exist\n please try again \n \n "

            ConnectDatabase
            
        fi
}

function DropDatabase {
    #clear
    echo -e "Your databases are : \n "
    ListDatabase
    echo "choose database name you want to drop without the '/' "
    read ddb 
    
    findDdb=`find -name $ddb 2>>/dev/null`

        if [ "./$ddb" = "$findDdb" ] 
            then
            echo "type yes to confirm droping or no to cancel"
            rm -Ir $ddb 
            echo "you have dropped $ddb"
            
        else
            echo -e "\nThis database doesn't exist\n\nClick Enter to back to CONNECT MENU"

            #DropDatabase
            
        fi

}

function MainMenu {
    #clear
        echo "Main Menu:"
        select choice in "Create Database" "List Databases" "Connect to Databases" "Drop Database" "Exit"
        do    
        case $choice in
            "Create Database" ) CreateDatabase ;;
            "List Databases" ) ListDatabase ;;
            "Connect to Databases" ) ConnectDatabase ;;
            "Drop Database" ) DropDatabase ;;
            "Exit" ) exit ;;
            * ) echo $REPLY is not one of the choices ;;
        esac
        done
}


cd DB-engine

MainMenu




