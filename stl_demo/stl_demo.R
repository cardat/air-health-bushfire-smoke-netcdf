stllc <- stl(log(co2), s.window = 21)
dat <- data.frame(stllc$time.series)
str(dat)
dat$rawdata <- dat$seasonal + dat$trend + dat$remainder
hist(dat$rawdata)
idx <- 40:60 # 1:nrow(dat)#
yl <- c(5.74, 5.78) # range(dat$rawdata) #
with(dat[idx,] , plot(idx, seasonal+trend+remainder, pch = 16, cex = .7, ylim = yl))
with(dat[idx,] , lines(idx, trend, col = 'red', lwd = 2))
with(dat[idx,] , lines(idx, seasonal+trend, col = 'green', lty = 2))
with(dat[idx,] , segments(idx, seasonal+trend,
                          idx, seasonal+trend+remainder, col = 'orange', lwd = 4))

legend("bottomright", legend = c("trend", "seas+trend", "remainder"), lty=c(1,2, 1), col = c('red', 'green', 'orange'))
## what is the distribution of the remainder?
hist(dat$remainder)
## how big is a 'big' remainder?
raw_2SD <- sd(dat$remainder)*2
segments(raw_2SD, 0, raw_2SD, 120, col = 'red', lwd = 2)

dev.off()
