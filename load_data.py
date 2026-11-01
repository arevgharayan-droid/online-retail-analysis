import pandas as pd
import sqlite3

df=pd.read_excel(
    'data/online_retail.xlsx',
    dtype={"InvoiceNo": str, "StockCode": str}
    )
df['CustomerID']=df['CustomerID'].astype('Int64')
print(df.shape)
print(df.dtypes)
print(df.isna().sum())

conn = sqlite3.connect("data/retail.db")
df.to_sql("raw_transactions", conn, if_exists="replace", index=False)
conn.close()

print("Done")