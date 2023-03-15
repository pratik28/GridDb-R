# importing packages
library(httr)
library(xml2) 
library(readr) 
library(jsonlite) 
library(ggplot2)

#Check if the GridDb cluster is accessible via secure Web API   
# base_url = "https://cloud1.griddb.com/trialxxxx/griddb/v2/gs_clustertrialxxxx/dbs/pratik" , i.e. https://[host]/griddb/v2/[clustername]/dbs/[databasename] 

my_base_url = "https://cloud1.griddb.com/trialxxxx/griddb/v2/gs_clustertrialxxxx/dbs/pratik" 
r <- GET(
	url = "https://cloud1.griddb.com/trial1502/griddb/v2/gs_clustertrial1502/dbs/pratik/checkConnection" , 
    add_headers("Content-Type" = "application/json; charset=UTF-8" ) ,      
    config = authenticate("pratik", "MyPASS1234"), 
    encode = "json" 
  )
print(r) 

#Construct a data object to hold the request body (i.e., the container that needs to be created)  

my_data_obj = '{ 
	"container_name":"Global_Health_Nutrition"  , 
	"container_type":"COLLECTION" ,   
	"rowkey": False,   
	"columns": [
	{ "name": "country_name" "type": " STRING" }, 
	{ "name": "country_code"	"type": "STRING" },  
	{"name": "indicator_name" "type": "STRING"},    
	{
	"name": "indicator_code"
	"type": "STRING "
    	},    
	{
	"name": "1960"
	"type": "FLOAT"
    	},    
	{
	"name": "score_1961"
	"type": "FLOAT"
    	},    
	{
	"name": "score_1962"
	"type": "FLOAT"
    	},  
		{
	"name": "score_1963"
	"type": "FLOAT"
    	}, 
		{
	"name": "score_1964"
	"type": "FLOAT"
    	}, 
		{
	"name": "score_1965"
	"type": "FLOAT"
    	}, 
		{
	"name": "score_1966"
	"type": "FLOAT"
    	},
		{"name": "score_1967" 	"type": "FLOAT"},{"name": "score_1968" 	"type": "FLOAT"},{"name": "score_1969" 	"type": "FLOAT"},{"name": "score_1970" 	"type": "FLOAT"},{"name": "score_1971" 	"type": "FLOAT"},{"name": "score_1972" 	"type": "FLOAT"},{"name": "score_1973" 	"type": "FLOAT"},{"name": "score_1974" 	"type": "FLOAT"},{"name": "score_1975" 	"type": "FLOAT"},{"name": "score_1976" 	"type": "FLOAT"},{"name": "score_1977" 	"type": "FLOAT"},{"name": "score_1978" 	"type": "FLOAT"},{"name": "score_1979" 	"type": "FLOAT"},{"name": "score_1980" 	"type": "FLOAT"},{"name": "score_1981" 	"type": "FLOAT"},{"name": "score_1982" 	"type": "FLOAT"},{"name": "score_1983" 	"type": "FLOAT"},{"name": "score_1984" 	"type": "FLOAT"},{"name": "score_1985" 	"type": "FLOAT"},{"name": "score_1986" 	"type": "FLOAT"},{"name": "score_1987" 	"type": "FLOAT"},{"name": "score_1988" 	"type": "FLOAT"},{"name": "score_1989" 	"type": "FLOAT"},{"name": "score_1990" 	"type": "FLOAT"},{"name": "score_1991" 	"type": "FLOAT"},{"name": "score_1992" 	"type": "FLOAT"},{"name": "score_1993" 	"type": "FLOAT"},{"name": "score_1994" 	"type": "FLOAT"},{"name": "score_1995" 	"type": "FLOAT"},{"name": "score_1996" 	"type": "FLOAT"},{"name": "score_1997" 	"type": "FLOAT"},{"name": "score_1998" 	"type": "FLOAT"},{"name": "score_1999" 	"type": "FLOAT"},{"name": "score_2000" 	"type": "FLOAT"},{"name": "score_2001" 	"type": "FLOAT"},{"name": "score_2002" 	"type": "FLOAT"},{"name": "score_2003" 	"type": "FLOAT"},{"name": "score_2004" 	"type": "FLOAT"},{"name": "score_2005" 	"type": "FLOAT"},{"name": "score_2006" 	"type": "FLOAT"},{"name": "score_2007" 	"type": "FLOAT"}, {"name": "score_2008" "type": "FLOAT"},{"name": "score_2009" 	"type": "FLOAT"},{"name": "score_2010" 	"type": "FLOAT"},{"name": "score_2011" 	"type": "FLOAT"},{"name": "score_2012" 	"type": "FLOAT"},{"name": "score_2013" 	"type": "FLOAT"},{"name": "score_2014" "type": "FLOAT" },  
	{
	"name": "score_2015"
	"type": "FLOAT"
    	}
      ]  #End of container columns 
  }'

#Set up the GridDB WebAPI URL
container_url = my_base_url + "/containers/"
#Lets now invoke the POST request via GridDB WebAPI with the headers and the request body 
r <- POST(container_url, 
       add_headers("Content-Type" = "application/json; charset=UTF-8" ) ,      
       config = authenticate("pratik", "MyPASS1234"), 
       encode = "json", 
      body= my_data_obj) 
	  
#showcontainer() 

# Populate the container with rows from CSV 
#import data in csv format
ghn_data <- read_csv("data.csv") 
#Convert the CSV to Json format and verify it worked by printing
ghn_data_JSON <- toJSON(ghn_data) 

insert_url = "base_url/containers/Global_Health_Nutrition/rows"  
r <- PUT(insert_url, 
       add_headers("Content-Type" = "application/json; charset=UTF-8" ) ,      
       config = authenticate("pratik", "MyPASS1234"), 
       body = ghn_data_JSON , 
       encode = "json" ) 

#To check if all rows have been inserted
print(str(json.loads(r.text)['count']) + ' rows have been registered in the container Global_Health_Nutrition.') 


#Fetch(Query) Top 10 countries with the highest per capita income , the indicator_code for which is NY.GNP.PCAP.CD. 
my_sql_query1 = '(f"""SELECT country_name, country_code,  score_2015 FROM Global_Health_Nutrition where indicator_code=\'NY.GNP.PCAP.CD\' ORDER BY score_2015 DESC LIMIT 10 """) '

#To retieve data from a GridDB container, the GridDB Web API Query URL must be suffied with "/sql" 
my_query_url = base_url + '/sql' 

#Construct the request body 
query_request_body = '[{"type":"sql-select", "stmt":"'+my_sql_query1+'", "limit" : 10}]' 
# print(query_request_body ) 
#Invoke the GridDB WebAPI request 
qr1 <- GET (url = my_query_url, 
       add_headers("Content-Type" = "application/json; charset=UTF-8" ) ,      
       config = authenticate("pratik", "MyPASS1234"), 
       body = query_request_body
       ) 
                             
#print(qr1) 
#Copy data returned into an R dataframe 
ghn_data <- qr1  
# Plot the bars 
barplot( ghn_data$Income, main="Top 10 Countries by per capita Income", names.arg = ghn_data$Country_Code  , xlab="CountryName", ylab="Per Capita Income", col="blue", args.legend="bottomright" )  

#Second query and analysis 
my_sql_query2 = '(f"""SELECT country_name, country_code,  score_2014 FROM Global_Health_Nutrition where indicator_code=\'SH.DTH.COMM.ZS\' ORDER BY score_2014 DESC LIMIT 20 """) '
barplot( ghn_data$Percent, main="Cause of death, by communicable diseases and maternal, prenatal and nutrition conditions", names.arg = ghn_data$CountryCode  , xlab="CountryName", ylab="Percent of Total", col="blue", args.legend="bottomright" )  

print("EOP, R and GridDB") 



