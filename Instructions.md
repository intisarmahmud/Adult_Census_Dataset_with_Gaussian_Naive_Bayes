# **INSTRUCTIONS**

1.  Loading necessary libraries:

    ``` r
    library(dplyr)
    ```

        ## 
        ## Attaching package: 'dplyr'

        ## The following objects are masked from 'package:stats':
        ## 
        ##     filter, lag

        ## The following objects are masked from 'package:base':
        ## 
        ##     intersect, setdiff, setequal, union

    ``` r
    library(caret)
    ```

        ## Loading required package: ggplot2

        ## Loading required package: lattice

2.  Loading dataset into data frame:

    ``` r
    data <- read.csv("D:/Important Files Study/Adult Census Dataset Work/Adult_Census.csv")
    ```

    *!!Please note that modify the path according to your file's drive
    location!!*

3.  Missing values handling:

    ``` r
    data[data == "?"] <- NA
    for (col in colnames(data)) {
    data[is.na(data[, col]), col] <- as.character(names(which.max(table(data[, col]))))
    }
    ```

4.  Conversion of catagorical columns to numeric columns:

    ``` r
    data <- data %>%
    mutate(across(where(is.factor), as.integer))
    ```

5.  Splitting dataset for training and testing purpose:

    ``` r
    #setting seed 42 for reproductibility
    set.seed(42)
    #here 80% of data is taken for training and rest for testing purpose 
    splitIndex <- createDataPartition(data$income, p = 0.8, list = FALSE)
    train_data <- data[splitIndex,]
    test_data <- data[-splitIndex,]
    ```

6.  Selection of numeric columns for Gaussian naive Bayes
    implementation:

    ``` r
    numeric_cols <- c("age", "fnlwgt", "education.num", "capital.gain", "capital.loss", "hours.per.week")
    ```

7.  Calculation of mean and standard deviation:

    ``` r
    means <- sapply(split(train_data[, numeric_cols], train_data$income), colMeans)
    sds <- sapply(split(train_data[, numeric_cols], train_data$income), apply, 2, sd)
    ```

8.  Declaration of Gaussian probability density function in short PDF:

    ``` r
    gaussian_pdf <- function(x, mean, sd) {
    exp(-((x - mean)^2 / (2 * sd^2))) / (sqrt(2 * pi) * sd)
    }
    ```

9.  Prediction with simple Gaussian naive Bayes:

    ``` r
    predict_gnb_simple <- function(test_data) {
    predictions <- numeric(nrow(test_data))
    for (i in 1:nrow(test_data)) {
     row <- test_data[i, ]
     scores <- sapply(1:ncol(means), function(j) {
       score <- log(length(train_data$income[train_data$income == unique(train_data$income)[j]]) / nrow(train_data))
       for (feature in names(row)) {
         if (feature %in% numeric_cols) {
           x <- row[feature]
           mean <- means[feature, j]
           stddev <- sds[feature, j]
           score <- score + log(gaussian_pdf(x, mean, stddev))
         } else {
           mode_val <- as.character(names(which.max(table(train_data[train_data$income == unique(train_data$income)[j], feature]))))
           if (row[feature] == mode_val) {
             score <- score + log(1)
           } else {
             score <- score + log(0 + 1e-6)
           }
         }
       }
       return(score)
     })
     predictions[i] <- which.max(scores)
      }
      return(predictions)
    }
    ```

    *!!Special note:it might take a little bit more time for lower end
    specs. So, hold tight while you do it. :)!!*

10. Prediction Evaluation:

``` r
predictions_simple <- predict_gnb_simple(train_data[, -ncol(train_data)])
#converting prediction into factors with level corresponding to the unique values in the 'income' column
predictions_simple <- factor(predictions_simple, levels = 1:length(unique(train_data$income)), labels =  unique(train_data$income))
```

11. Confusion matrix and performance metrics:

``` r
#confusion matrics
confusion_simple <- table(predictions_simple, train_data$income)
print(confusion_simple)
```

    ##                   
    ## predictions_simple <=50K  >50K
    ##              <=50K 13145   702
    ##              >50K   6631  5571

``` r
confusion <- confusion_simple
accuracy <- sum(diag(confusion)) / sum(confusion)
cat("Accuracy:", accuracy, "\n")
```

    ## Accuracy: 0.7184921

``` r
#precision calculation(The proportion of true positives out of all predicted positives)
precision <- diag(confusion) / rowSums(confusion)
cat("Precision for '<=50K':", precision["<=50K"], "\n")
```

    ## Precision for '<=50K': 0.9493031

``` r
cat("Precision for '>50K':", precision[">50K"], "\n")
```

    ## Precision for '>50K': 0.4565645

``` r
#recall calculation(The proportion of true positives out of all actual positives)
recall <- diag(confusion) / colSums(confusion)
cat("Recall for '<=50K':", recall["<=50K"], "\n")
```

    ## Recall for '<=50K': 0.6646946

``` r
cat("Recall for '>50K':", recall[">50K"], "\n")
```

    ## Recall for '>50K': 0.8880918

``` r
#f1 score calculation(The harmonic mean of precision and recall)
f1_score <- 2 * (precision * recall) / (precision + recall)
cat("F1 Score for '<=50K':", f1_score["<=50K"], "\n")
```

    ## F1 Score for '<=50K': 0.7819052

``` r
cat("F1 Score for '>50K':", f1_score[">50K"], "\n")
```

    ## F1 Score for '>50K': 0.6030853

``` r
#specificity calculation(the ratio of correctly predicted negative observations to all actual negative observations)
specificity <- c()
for (i in 1:nrow(confusion)) {
true_negatives <- sum(confusion) - (sum(confusion[, i]) + sum(confusion[i, ]) - confusion[i, i])
false_positives <- sum(confusion[, i]) - confusion[i, i]
specificity[i] <- true_negatives / (true_negatives + false_positives)
}
cat("Specificity for '<=50K':", specificity[1], "\n")
```

    ## Specificity for '<=50K': 0.4565645

``` r
cat("Specificity for '>50K':", specificity[2], "\n")
```

    ## Specificity for '>50K': 0.9493031
