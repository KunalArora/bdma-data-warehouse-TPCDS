{
    if ($0 ~ /create table.*/) {
        split($0, arr, " ");
        
        for ( i in arr ) {
            if (i == 2) {
                printf ("external ");
                printf (arr[i]);
                printf (" ");
            }
            else if (i == 3) {
                print arr[i];
                table_name = arr[i] # Saving the current table name
            }
            else {
                printf (arr[i]);
                printf (" ");
            }
        }
    }
    else if ($0 ~ /^\);$/) {
        match($0, /;$/);
        new_line = substr($0, 1, RSTART-1);
        print new_line
        print "ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'"
        printf "LOCATION '${DATA_DIR}/"
        printf table_name
        print "';";
    }
    else {
        print $0;
    }

}