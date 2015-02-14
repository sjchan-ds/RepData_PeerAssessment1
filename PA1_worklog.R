
setwd("C:/Users/SJ/RepData_PeerAssessment1")
getwd()
###[1] "C:/Users/SJ/RepData_PeerAssessment1"

## using knitr to produce the HTML file
library(knitr)
knit2html("PA1_template.Rmd")
browseURL("PA1_template.html")


=================================================
## (0) Loading and preprocessing the data


## unzip the data:
unzip("activity.zip")

## (A) Loading and Precessing the data

## 1. load the data (i.e. read.csv)
activity <- read.csv("activity.csv")

str(activity) ## examine the data structure 
##'data.frame':	17568 obs. of  3 variables:
## $ steps   : int  NA NA NA NA NA NA NA NA NA NA ...
## $ date    : Factor w/ 61 levels "2012-10-01","2012-10-02",..: 1 1 1 1 1 1 1 1 1 1 ...
## $ interval: int  0 5 10 15 20 25 30 35 40 45 ...

## 2. Process/transform the data (if necessary) into a format suitable for the current analysis



####============================================
## (B) What is mean of total number of steps taken per day

## For this part of the assignment, you can ignore the missing values in the dataset

## 1. Calculate the total number of steps taken per day

## aggrgate is a generic function with methods for data frames and time series
## Spits the ata into subsets, computers, summary statistics for each, and return the results 

activityDailySum <- aggregate(steps ~ date, data = activity, FUN=sum)

## examine the structure of new data frame "activityDailySum"
> str(activityDailySum)
'data.frame':	53 obs. of  2 variables:
 $ date : Factor w/ 61 levels "2012-10-01","2012-10-02",..: 2 3 4 5 6 7 9 10 11 12 ...
 $ steps: int  126 11352 12116 13294 15420 11015 12811 9900 10304 17382 ...
> 

## 2. If you do not understand the difference a histogram and a barplot, research the difference
##       between them. Make a histogram of the total number of steps taken each day.

hist(activityDailySum$steps, xlab="Total steps per day", ylab="counts", 
                             main="Total number of steps taken each day", 
                             col="blue")

## 3. Calculate and report the mean and median of the total number of steps taken per day
##

## The mean of the total number of steps taken per day
meanStepsDaily <- mean(activityDailySum$steps)

##> meanStepsDaily
##[1] 10766.19

## The meadian of the total number of steps taken per day
medianStepsDaily <- median(activityDailySum$steps)

> medianStepsDaily
[1] 10765


###==================================================================================
## (C) What is the average daily activity pattern?

## 1. Make a time series plot (i.e. type = "l", ) of the 5-minute interval (x-axis) and 
##    the average number of steps taken, averaged across all days (y-axis)

intervalAveSteps <- aggregate(steps ~ interval, data = activity, FUN=mean)

plot(intervalAveSteps, type="l", xlab="5-minute interval",
          main="Daily average number of steps per 5 min-interval",
          col = "blue")
          
## 2. Which 5-minute interval, on average across all the days in the dataset, contains the
##    maximum number of steps?

intervalMaxNumberSteps <- intervalAveSteps$interval[which.max(intervalAveSteps$steps)]

intervalMaxNumberSteps
##[1] 835

###=======================================================================================
##(D) Imputing missing values
## Note that there are a number of days/intervals where there are missing values (coded as NA). 
## The presence of missing days may introduce bias into some calculations or summaries of the 
## data. 

## 1. Calculate and report the total number of missing values in the dataset (i.e. the total
##    number of rows with NAs) 

naNum <- sum(is.na(activity))
naNum
## [1] 2304


## 2. Devise a strategy for filling in all of the missing values 
##    in the dataset. The strategy does not need to be sophisticated. For example, you could 
##    use the mean/median for that day, or the mean for that 5-minute interval, etc.

#### check the dimension of the original data frame 'activity' with NA in the column named "steps"
dim(activity)
[1] 17568     3

    
### define a function called imputeMean to replace the missing data NA with
####    the mean of the total number of steps taken per day (daily mean steps)
    imputeMean <- function(x) replace(x, is.na(x), mean(x, na.rm = TRUE))
    
#### Using the package plyr to create a new data frame with the imputed data. 
     library(plyr)
     tmpDFRM <- ddply(activity, ~interval, transform, steps = imputeMean(steps))
     
#### Need to reorder the new data frame "activityNew" due to the fact that plyr orders by group.
     activityNew <- tmpDFRM[with(tmpDFRM, order(date, interval)), ]
    
     

## 3. Create a new dataset that is equal to the original dataset but with the missing data filled in.


#### Need to reorder the new data frame "activityNew" due to the fact that plyr orders by group.
     activityNew <- tmpDFRM[with(tmpDFRM, order(date, interval)), ]



## 4. Make a histogram of the total number of steps taken each day and Calculate and report the mean
      and median total number of steps taken per day. Do these values differ from the estimates from 
      the first part of the assignment? What is the impact of imputing missing data on the estimates 
      of the total daily number of steps?

activityNewDailySum <- aggregate(steps ~ date, data = activityNew, FUN=sum)

## examine the structure of new data frame "activityDailySum"
##str(activityNewDailySum)
##'data.frame':	61 obs. of  2 variables:
## $ date : Factor w/ 61 levels "2012-10-01","2012-10-02",..: 1 2 3 4 5 6 7 8 9 10 ...
## $ steps: num  10766 126 11352 12116 13294 .....
> 

## plot a historgram of the total number of steps taken each day with new data frame
hist(activityNewDailySum$steps, xlab="Total steps per day with replaced mean", ylab="counts", 
                             main="Total number of steps taken each day", 
                             col="green")


## The mean of the total number of steps taken per day from the new data frame
meanNewStepsDaily <- mean(activityNewDailySum$steps)
meanNewStepsDaily
###[1] 10766.19
 

## The meadian of the total number of steps taken per day from the new data frame
medianNewStepsDaily <- median(activityNewDailySum$steps) 
medianNewStepsDaily
##[1] 10766.19
      

#### =================================================================================================
### (E) Are there differences in activity patterns between weekdays and weekends?
###   For this part the weekdays() function may be of some help here. 
###   Use the dataset with the filled-in missing values for this part. 
###  
###   1. Create a new factor variable in the dataset with two levels – “weekday” and “weekend” 
###      indicating whether a given date is a weekday or weekend day.
   
         ## create a new factor variable "weekday" indicating whether a given date
         ## is a weekend or weekday and add to the new data set 'activityNew'
         
         activityNew$weekday <- weekdays(strptime(activityNew$date, format="%Y-%m-%d"))
         weekend <- (activityNew$weekday == "Saturday") | (activityNew$weekday == "Sunday")
         activityNew$weekday[weekend]  <- "weekend"
         activityNew$weekday[!weekend] <- "weekday"
         

   
###   2. Make a panel plot containing a time series plot (i.e. type = "l") of the 5-minute interval 
###      (x-axis) and the average number of steps taken, averaged across all weekday days or weekend
###      days (y-axis). See the README file in the GitHub repository to see an example of what this 
###      plot should look like using simulated data.


## change activityNew$weekday into factor
activityNew$weekday <- factor(activityNew$weekday)
     
## estimate the mean steps per day for weekdays and for weekend        
activityNewMWday <- aggregate(x = activityNew$steps, 
                         by = list(activityNew$interval, activityNew$weekday),
                         FUN = mean)
                         
## provided proper column names to the new data frame 'activityNewMWday
colnames(activityNewMWday) <- c("interval", "weekday", "steps")                         
 
## make a panel plot containing a time series plot of 5-minutes intervals and the average number
##  number of steps taken

 library(lattice)
 xyplot(steps ~ interval | weekday, data = activityNewMWday, layout=c(1,2), type="l",
        ylab ="Number of steps")
    
    
      -----------------------------------------------------------------
     ### alternative approach (to cross-check the usage of aggregate is okay
      
    
      par(mfrow = c(2,1))
     ## for (type in c("weekend", "weekday")) {
      
           type = "weekend"
           steps.type_wend <- aggregate(steps ~ interval, data = activityNew, 
                                   subset = activityNew$weekday == type, FUN = mean)
           plot(steps.type_wend, type="l", main=type)
           
           type <- "weekday"   
           steps.type_wday <- aggregate(steps ~ interval, data = activityNew, 
                                   subset = activityNew$weekday == type, FUN = mean)
           plot(steps.type_wday, type="l", main=type)
           
     ## }
     
  