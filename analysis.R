## Car Insurance Claims Risk Analysis
## Data: dataCar (insuranceData package) - 67,856 Australian auto policies, 2004-05

d <- read.csv("dataCar.csv")

# Clean up / relabel for readability
d$agecat <- factor(d$agecat, labels = c("1 (youngest)","2","3","4","5","6 (oldest)"))
d$veh_age <- factor(d$veh_age, labels = c("1 (newest)","2","3","4 (oldest)"))
d$area <- factor(d$area)

out_dir <- "plots"
dir.create(out_dir, showWarnings = FALSE)

## ---- Portfolio-level summary ----
n <- nrow(d)
total_exposure <- sum(d$exposure)
total_claims <- sum(d$numclaims)
total_cost <- sum(d$claimcst0)
overall_freq <- total_claims / total_exposure          # claims per exposure-year
avg_sev <- total_cost / total_claims                     # avg cost per claim
pure_premium <- total_cost / total_exposure              # expected loss per exposure-year

cat("=== Portfolio Summary ===\n")
cat(sprintf("Policies: %d | Total exposure: %.0f policy-years\n", n, total_exposure))
cat(sprintf("Claim frequency: %.4f claims per exposure-year\n", overall_freq))
cat(sprintf("Average severity: $%.0f per claim\n", avg_sev))
cat(sprintf("Portfolio pure premium: $%.2f per exposure-year\n\n", pure_premium))

## ---- Helper: frequency & severity by a rating factor ----
summarize_by <- function(data, factor_col) {
  agg <- aggregate(cbind(numclaims, claimcst0, exposure) ~ data[[factor_col]],
                    data = data, FUN = sum)
  names(agg)[1] <- factor_col
  agg$frequency <- agg$numclaims / agg$exposure
  claims_only <- data[data$numclaims > 0, ]
  sev <- aggregate(claimcst0 / numclaims ~ claims_only[[factor_col]],
                    data = claims_only, FUN = mean)
  names(sev) <- c(factor_col, "avg_severity")
  merge(agg, sev, by = factor_col, all.x = TRUE)
}

age_summary <- summarize_by(d, "agecat")
vehage_summary <- summarize_by(d, "veh_age")
area_summary <- summarize_by(d, "area")

print(age_summary)
print(vehage_summary)
print(area_summary)

## ---- Graph 1: Claim frequency by driver age category ----
png(file.path(out_dir, "freq_by_age.png"), width = 900, height = 650, res = 130)
bp <- barplot(age_summary$frequency, names.arg = age_summary$agecat,
              col = "#2c5f8a", border = NA,
              main = "Claim Frequency by Driver Age Category",
              xlab = "Driver Age Category", ylab = "Claims per Exposure-Year",
              ylim = c(0, max(age_summary$frequency) * 1.2))
text(bp, age_summary$frequency, labels = round(age_summary$frequency, 3), pos = 3, cex = 0.8)
dev.off()

## ---- Graph 2: Average severity by driver age category ----
png(file.path(out_dir, "sev_by_age.png"), width = 900, height = 650, res = 130)
bp <- barplot(age_summary$avg_severity, names.arg = age_summary$agecat,
              col = "#a4373a", border = NA,
              main = "Average Claim Severity by Driver Age Category",
              xlab = "Driver Age Category", ylab = "Average Cost per Claim ($)",
              ylim = c(0, max(age_summary$avg_severity, na.rm = TRUE) * 1.2))
text(bp, age_summary$avg_severity, labels = round(age_summary$avg_severity, 0), pos = 3, cex = 0.8)
dev.off()

## ---- Graph 3: Claim frequency by vehicle age ----
png(file.path(out_dir, "freq_by_vehage.png"), width = 900, height = 650, res = 130)
bp <- barplot(vehage_summary$frequency, names.arg = vehage_summary$veh_age,
              col = "#3a7d44", border = NA,
              main = "Claim Frequency by Vehicle Age",
              xlab = "Vehicle Age Category", ylab = "Claims per Exposure-Year",
              ylim = c(0, max(vehage_summary$frequency) * 1.2))
text(bp, vehage_summary$frequency, labels = round(vehage_summary$frequency, 3), pos = 3, cex = 0.8)
dev.off()

## ---- Graph 4: Claim frequency by geographic area ----
png(file.path(out_dir, "freq_by_area.png"), width = 900, height = 650, res = 130)
bp <- barplot(area_summary$frequency, names.arg = area_summary$area,
              col = "#8a5a2c", border = NA,
              main = "Claim Frequency by Geographic Area",
              xlab = "Area", ylab = "Claims per Exposure-Year",
              ylim = c(0, max(area_summary$frequency) * 1.2))
text(bp, area_summary$frequency, labels = round(area_summary$frequency, 3), pos = 3, cex = 0.8)
dev.off()

## ---- Graph 5: Relative pure premium by age category (indexed to portfolio avg) ----
age_summary$pure_premium <- age_summary$claimcst0 / age_summary$exposure
age_summary$relativity <- age_summary$pure_premium / pure_premium

png(file.path(out_dir, "relativity_by_age.png"), width = 900, height = 650, res = 130)
bp <- barplot(age_summary$relativity, names.arg = age_summary$agecat,
              col = ifelse(age_summary$relativity > 1, "#a4373a", "#2c5f8a"), border = NA,
              main = "Pure Premium Relativity by Driver Age\n(1.0 = portfolio average)",
              xlab = "Driver Age Category", ylab = "Relativity to Portfolio Average",
              ylim = c(0, max(age_summary$relativity) * 1.2))
abline(h = 1, lty = 2, col = "gray40")
text(bp, age_summary$relativity, labels = round(age_summary$relativity, 2), pos = 3, cex = 0.8)
dev.off()

# Save summary tables for the memo
write.csv(age_summary, "age_summary.csv", row.names = FALSE)
write.csv(vehage_summary, "vehage_summary.csv", row.names = FALSE)
write.csv(area_summary, "area_summary.csv", row.names = FALSE)

cat("\nDone. Plots saved to plots/, summary tables saved as CSVs.\n")
