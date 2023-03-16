

		**<span style="text-decoration:underline;">Statistical analysis of GridDB data, using R</span>**

**Introduction to GridDB. **

GridDB is an in-memory database, that allows a vast quantity of data to be stored and searched quickly and safely..

A GridDb instance is made of nodes, nodes are database management processes, each node requires a physical machine for itself to run. 

A group of such nodes is called "Cluster" , the cluster service is started when all the nodes in the cluster are up and running, and all of them join the cluster. 




![alt_text](images/arc_DataModel.png "image_tooltip")


@Source: [https://www.toshiba-sol.co.jp/en/pro/griddb/docs-en/v4_3_2/GridDB_QuickStartGuide.html](https://www.toshiba-sol.co.jp/en/pro/griddb/docs-en/v4_3_2/GridDB_QuickStartGuide.html) \


Somewhat similar to the idea of a table in a relational database, GridDB gives the abstraction of a "container". 

A container has a schema, can hold data and can be indexed. 

GridDB guarantees the ACID characteristic of data for each container. 

GridDB offers two types of containers :- 

1.  'Collections' 

2. 'Time Series' containers  

Within a database, there might be multiple containers, akin to tables in a relational database. 

These containers hold the data in rows. 

**Introduction to R **

R is a modern programming language, suitable for complex mathematical calculations, statistical analysis, creating charts and machine learning models. . 

It was developed by Ross Ihaka and Robert Gentleman at the University of Auckland, New Zealand. 

The name of both of its creators start with the letter "R", hence the name given to the programming language. 

We chose R for our evaluations as R is gaining a lot of prominence in this era of big data analytics and machine learning. 

We will discuss how you can create containers and save data in GridDb via its Web API, and later query the data and analyse it through R. 

 



* Install R and HTTR package and other packages 

You can load additional packages via the "Load Packages" menu option under the "Packages" menu. 

We choose HTTR as we will connect to GridDB cloud instances via GridDB's web API. 

We will also use some other packages like "readr" and "jsonlite" etc. , for reading CSV files and processing JSON respectively. 

We use Web API as its simple and relieves the need of using an additional database connectivity package ODBC/JDBC. 

Also, GridDB SE as well as GridDB AE both versions support Web APIs, whereas GridDB SE does not support JDBC/ODBC. 

We can check if the required libraries HTTR and XML have been loaded in our R environment using the sessionInfo() command 

The output of the sessionInfo() command looks like this on my windows machine.  




![alt_text](images/sessionInfo-output.png "image_tooltip")


You can see that the required packages were loaded under the "other attached packages:" section. 

If you want to do this from the R command line instead, use the below commands to install and include packages in your code. 

install packages('httrr')

install packages('readr')

install.packages('jsonlite')



* Connect to GridDb via HTTPS connection ( Web API). 

This method gives maximum flexibility and ease as you're not dependent on any driver or technology to connect to the database.  

You just use the simplest access methods via the secure Web API  

The GridDB URLs are of the form :-  **'https://[host]/griddb/v2/[clustername]/dbs/[databasename]' **; where a cluster might be running multiple databases managed by a single  database server instance. 

In my case, my base url looks like this:- 

base_url = "https://cloud1.griddb.com/trialxxxx/griddb/v2/gs_clustertrialxxxx/dbs/pratik"  

Lets first check if GridDb allows you a connection, we will check this via the checkConnection method of the Web API.  \


_r &lt;- GET(_

_	url = "https://cloud1.griddb.com/trialxxxx/griddb/v2/gs_clustertrialxxxx/dbs/pratik/checkConnection" , _

_    add_headers("Content-Type" = "application/json; charset=UTF-8" ) ,      _

_    config = authenticate("pratik", "MyPASS1234"), _

_    encode = "json" _

_  )_

_print(r) _

If you see a "Status: 200" in the printed response, the server is ready to accept your connections. 

While we're checking the web based access, we also confirm that secure authenticated access via HTTPS is available , as we provide the username/password. 



* The data to be used 

The data that we are going to use for this demonstration is about some economic and demographic parameters, measured in the world's major countries between 1960-2015. 

Below is a snippet about the same:-  



![alt_text](images/data-snapshot.png "image_tooltip")


Countries are given scores on many criteria like Health/Education/Income/Population ratios etc., it can be found here:- 

https://data.world/data-society/global-health-nutrition-data 

To hold this data we must create a container(~table ) in GridDB. 

So, we send a POST request to the cluster with details of the container structure we need. 

#Construct a data object to hold the request body (i.e., the container that needs to be created)

_my_data_obj = {_

_    "container_name": "Global_Health_Nutrition", _

_    "container_type": "COLLECTION",_

_    "rowkey": False,  _

_    "columns": [_

_	{_

_	"name": "country_name"_

_	"type": " STRING"_

_    	},    _

_	{_

_	"name": "country_code"_

_	"type": "STRING"_

_    	},    _

_	{_

_	"name": "indicator_name"_

_	"type": "STRING"_

_    	},    _

_	{_

_	"name": "indicator_code"_

_	"type": " "_

_    	},    _

_	{_

_	"name": "1960"_

_	"type": "FLOAT"_

_    	},    _

_	{_

_	"name": "score_1961"_

_	"type": "FLOAT"_

_    	},    _

_	{_

_	"name": "score_1962"_

_	"type": "FLOAT"_

_    	},  _

_	....... _

_	......_

_	{_

_	"name": "score_2014"_

_	"type": "FLOAT"_

_    	},  _

_	{_

_	"name": "score_2015"_

_	"type": "FLOAT"_

_    	}_

_      ]  #End of container columns _

_  }_

_#Set up the GridDB WebAPI URL_

_container_url = base_url + '/containers' _

_#Lets now invoke the POST request via GridDB WebAPI with the headers and the request body _

_r &lt;- POST(container_url, _

_       add_headers("Content-Type" = "application/json; charset=UTF-8" ) ,      _

_       config = authenticate("pratik", "MyPASS1234"), _

_       encode = "json", _

_      data= my_data_obj)_

To check if the container was indeed created, you can use the "showcontainer" command, it will list all the containers in your database. 



* Now lets define a function to insert data into the GridDB database. 

We will use R language's innate ability to process CSV files here. 

Instead of adding rows to a database table 1 by 1 OR creating a huge POST request, we just tell R to use a CSV file, and the language takes care of adding the rows on its own.  

We use read_csv function of R, which reads a CSV and returns a **tibble** ( not a full fledged data frame), a tibble is a simple data structure and can easily be fed to a POST Web API 

request. 

_library(readr)_

_library(jsonlite)_

_#import data in csv format_

_ghn_data &lt;- read_csv("data.csv") _

_#Convert the CSV to Json format and verify it worked by printing_

_ghn_data_JSON &lt;- toJSON(ghn_data) _

Now we have all the CSV data in JSON format, ready to be used in the web request. 

When POST()ing, you can include data in the body of the request. httr allows you to supply this in a number of different ways like named list, string or data frame etc. 

Also, GridDB's web API gives you a simple URL to PUT to when you want to add rows ( populate) data into containers. 

It takes the form of :- 

**base_url + '/containers/Container_Name/rows' **

So, for us insert_url = container_url+'Global_Health_Nutrition'+'/rows' OR  "base_url/containers/Global_Health_Nutrition/rows" 

We now have our PUT request for inserting rows(RowRegistration) as:- 

_r &lt;- PUT(insert_url, _

_       add_headers("Content-Type" = "application/json; charset=UTF-8" ) ,      _

_       config = authenticate("pratik", "MyPASS1234"), _

_       body = ghn_data_JSON , _

_       encode = "json" ) _

_#To check if all rows have been inserted_

_print(str(json.loads(x.text)['count']) + ' rows have been registered in the container Global_Health_Nutrition.')_




![alt_text](images/rows-inserted.png "image_tooltip")


 
We can populate more containers like this. 



* QUERY data via SELECT - first check with a simple query 

We will try to assess some economic parameters of the countries in the World. 

So, some of the data which contains health/medical will not be used, but we keep it for future use. Also, we will be using comparatively recent data from after 2010, and leave the data from 1960-2009. Another reason for leaving the historical data is that some older statistics/numbers for many countries are missing.   

**(i) **Let's check the countries with the highest per capita income , the indicator_code for which is **NY.GNP.PCAP.CD**.  \


_my_sql_query1 = (f"""SELECT country_name, country_code,  score_2015 FROM Global_Health_Nutrition where indicator_code='NY.GNP.PCAP.CD' """) _

_To retrieve data from a container, the URL must be suffixed with "/sql" , so our _

_my_query_url = base_url + '/sql' _

_#Construct the request body,  remember we're using the web API and cannot use inbuilt R functions like dbGetQuery()/dbInsertTable(),  hence we construct the request as below. _

_//requests.post(url, data=query_request_body, headers=header_obj) _

_query_request_body = '[{"type":"sql-select", "stmt":"'+my_sql_query1+'", "limit" : 10}]' _

_#Invoke the GridDB WebAPI request _

_qr1 &lt;- GET (url = my_query_url, _

_       add_headers("Content-Type" = "application/json; charset=UTF-8" ) ,      _

_       config = authenticate("pratik", "MyPASS1234"), _

_       body = query_request_body_

_       )                              _

_print(qr1) _

The data that is returned is something like this:- 



![alt_text](images/Top10-per-capita.png "image_tooltip")


_ghn_data &lt;- qr1  \
_

We just copied the data in a data frame ghn_data. 

To get a subset of ghn_data, like all country names, we can just use _ghn_data$Country_Name_

Now let's plot this data using the barplot function of R.  

Unless you visualise something via pictures/charts, the inherent message is either not very clear or you miss the audacity of the results.  

The general syntax of this function is:- 

**barplot(H, xlab, ylab, main, names.arg, col, args.legend)** where 

**H:** This parameter is a vector or a matrix containing numeric values which are used in a bar chart.   

**xlab** and **ylab **are labels of x-axis and y-axis repectively 

**main**: chart title 

**names.arg**: Cector of names or strings, appearing under each bar 

**col**: color of the bars 

**args.legend**: optional, determines where the legend will be placed and displayed.  

# print ghn_data and country_names, just for illustrating the data , then plot the graph 

_print(ghn_data ) _

_print(country_names)_

_barplot( ghn_data$Income, main="Top 10 Countries by per capita Income", names.arg = ghn_data$Country_Code  , xlab="CountryName", ylab="Per Capita Income", col="blue", _

_args.legend="bottomright" )  _






![alt_text](images/bar-graph-and-data.png "image_tooltip")
 

The above image shows the data and the shortened bar graph, the actual full chart looks like this below. 






![alt_text](images/Full-bar-graph.png "image_tooltip")


**(ii)**  Let's fire another query on GridDB, and analyse the results via R and plot the results . 

We will find the top countries based on the factor "Cause of death, by communicable diseases and maternal, prenatal and nutrition conditions (% of total) ". 

This data, e.g., is important for organisations working on public health, specially in poorer countries. 

Keeping the other calls same, we just change the query to ( only bottom 20 results) :- 

_my_sql_query2 = (f"""SELECT country_name, country_code,  score_2014 FROM Global_Health_Nutrition where indicator_code='SH.DTH.COMM.ZS' ORDER BY score_2014 DESC  LIMIT 20 """) _

Our bar plot function will look like:- 

_barplot( ghn_data$Percent, main="Cause of death, by communicable diseases and maternal, prenatal and nutrition conditions", names.arg = ghn_data$CountryCode  , _

_xlab="CountryName", ylab="Percent of Total", col="blue", args.legend="bottomright" ) _

The bar plot looks like this:-  \





![alt_text](images/cause_death.png "image_tooltip")




* To Conclude, we have demonstrated the capabilities of GridDB, a fast in-memory database that lends itself well for not only fast querying but also analytics. 

GridDB can work with multiple languages and has data connectors for  most popular tools. 

Transitioning to GridDb is easy as it follows almost similar syntax as other database products. 

GridDB's fast query and analytics engine adds power and speed to your queries. 

GridDb's error messages are easy to understand, pin-pointed and give you a clear indication of where the trouble might be.  
