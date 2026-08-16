import duckdb

con = duckdb.connect()

# Execute script
with open('extract_player_general_info.sql', 'r', encoding='utf-8') as f:
    con.sql(f.read())

# Query the extracted views
con.sql("SELECT * FROM v_player_basic_info").show()
con.sql("SELECT * FROM v_player_transfers").show()
con.sql("SELECT * FROM v_player_total_stats").show()
