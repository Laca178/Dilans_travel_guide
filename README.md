# Dilans_travel_guide
A quick user data analysis of a fictional online business. 

This is the solution of my final assignment in the Junior Data Scientist Academy online course @ data36.com.
------------------------------------------------------------------------------------------------------------
My task was to perform a quick data analysis (within 10-12 hours) and give insights for the marketing decisions of this online business (Dilan's Travel Guide). 

Dilan is a world traveler and he writes a travel blog where he sells an e-book and a video course.

On his blog he has thousands of readers every day, coming from three sources: Reddit, SEO and AdWords. And his blog is only available in 8 different countries. 

Dilan spends $1000 a month on marketing:
    for Adwords advertisement ($500 a month for paid ads),
    for SEO ($250 a month for editing) and
    for Reddit ($250 for content creation)

The dataset was a large raw log file covering 3 months of user activity, including article reads, subscriptions and purchase events. 

There were 3 questions to be answered in a 10-20 slide presentation:
--------------------------------------------------------------------  
  1. In which country should he prioritise his effort and why?

  2. Any other advice to Dilan on how to be smart with his investments based on the data from the last 3 months?

  3. Can you see any more interesting information (beyond the above 2 questions) in the data from which Dilan could profit?

I performed the task in the following order:
--------------------------------------------
  1. I used bash to download the dataset and separate the data into different tables based on the type of events:
    https://github.com/Laca178/Dilans_travel_guide/blob/main/20230507_Monok_Laszlo_Dilan's_travel_guide_bash_codebase.txt

  2. Loaded the data tables into a PostgreSQL database to perform an exploratory analysis and run several queries to answer the questions:
    https://github.com/Laca178/Dilans_travel_guide/blob/main/20230507_Monok_Laszlo_Dilan's_travel_guide.sql

  3. I collected the results of the individual queries into an Excel spreadsheet, in order to quickly create aesthetic visualizations of my results:
    https://github.com/Laca178/Dilans_travel_guide/blob/main/20230507_Monok_Laszlo_Dilan's_travel_guide_visualization.xlsx

  4. Finally I created a PowerPoint presentation with my graphs and the explanation of my insights: 
    https://github.com/Laca178/Dilans_travel_guide/blob/main/20230507_Monok_Laszlo_Dilan's_travel_guide.pdf
