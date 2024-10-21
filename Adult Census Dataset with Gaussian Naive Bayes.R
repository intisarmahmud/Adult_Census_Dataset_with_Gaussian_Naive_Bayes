library(dplyr)
library(caret)

data <- read.csv("D:/Important Files Study/Adult Census Dataset Work/Adult_Census.csv")

data[data == "?"] <- NA
for (col in colnames(data)) {
  data[is.na(data[, col]), col] <- as.character(names(which.max(table(data[, col]))))
}

data <- data %>%
  mutate(across(where(is.factor), as.integer))

set.seed(42)
splitIndex <- createDataPartition(data$income, p = 0.8, list = FALSE)
train_data <- data[splitIndex,]
test_data <- data[-splitIndex,]

numeric_cols <- c("age", "fnlwgt", "education.num", "capital.gain", "capital.loss", "hours.per.week")

means <- sapply(split(train_data[, numeric_cols], train_data$income), colMeans)
sds <- sapply(split(train_data[, numeric_cols], train_data$income), apply, 2, sd)

gaussian_pdf <- function(x, mean, sd) {
  exp(-((x - mean)^2 / (2 * sd^2))) / (sqrt(2 * pi) * sd)
}

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

predictions_simple <- predict_gnb_simple(train_data[, -ncol(train_data)])

predictions_simple <- factor(predictions_simple, levels = 1:length(unique(train_data$income)), labels = unique(train_data$income))

confusion_simple <- table(predictions_simple, train_data$income)
print(confusion_simple)

confusion <- confusion_simple
accuracy <- sum(diag(confusion)) / sum(confusion)
cat("Accuracy:", accuracy, "\n")

precision <- diag(confusion) / rowSums(confusion)
cat("Precision for '<=50K':", precision["<=50K"], "\n")
cat("Precision for '>50K':", precision[">50K"], "\n")

recall <- diag(confusion) / colSums(confusion)
cat("Recall for '<=50K':", recall["<=50K"], "\n")
cat("Recall for '>50K':", recall[">50K"], "\n")

f1_score <- 2 * (precision * recall) / (precision + recall)
cat("F1 Score for '<=50K':", f1_score["<=50K"], "\n")
cat("F1 Score for '>50K':", f1_score[">50K"], "\n")

specificity <- c()
for (i in 1:nrow(confusion)) {
  true_negatives <- sum(confusion) - (sum(confusion[, i]) + sum(confusion[i, ]) - confusion[i, i])
  false_positives <- sum(confusion[, i]) - confusion[i, i]
  specificity[i] <- true_negatives / (true_negatives + false_positives)
}
cat("Specificity for '<=50K':", specificity[1], "\n")
cat("Specificity for '>50K':", specificity[2], "\n")







