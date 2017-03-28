#!/usr/bin/env Rscript

library(ggplot2)
library(scales)
library(sitools)

data.standard <- read.csv("standard.dat", head=TRUE, sep=",")
data.cfarmhash <- read.csv("cfarmhash.dat", head=TRUE, sep=",")
data.farmhash <- read.csv("farmhash.dat", head=TRUE, sep=",")
data.cityhash <- read.csv("cityhash.dat", head=TRUE, sep=",")
data.murmurhash3 <- read.csv("murmurhash3.dat", head=TRUE, sep=",")
data.spookyv2 <- read.csv("spookyv2.dat", head=TRUE, sep=",")
data.clhash <- read.csv("clhash.dat", head=TRUE, sep=",")

graph <- ggplot(legend = TRUE) + 
  ggtitle('Hash function benchmark') +
  theme(plot.title = element_text(size = 10), 
        axis.title.x = element_text(size = 8), axis.title.y = element_text(size = 8),
        axis.text.x = element_text(size = 8), axis.text.y = element_text(size = 8)) + 
  geom_line(data = data.standard, aes(x = size, y = rate, colour = "C++11 std::hash")) +
  geom_line(data = data.cfarmhash, aes(x = size, y = rate, colour = "cfarmhash")) +
  geom_line(data = data.farmhash, aes(x = size, y = rate, colour = "farmhash")) +
  geom_line(data = data.cityhash, aes(x = size, y = rate, colour = "cityhash")) +
  geom_line(data = data.murmurhash3, aes(x = size, y = rate, colour = "murmurhash3")) +
  geom_line(data = data.spookyv2, aes(x = size, y = rate, colour = "spookyv2")) +
  geom_line(data = data.clhash, aes(x = size, y = rate, colour = "clhash")) +
  scale_y_continuous(labels = comma) +
  scale_x_continuous(labels = comma) +
  scale_colour_manual("",
                      values = c("#000000", "#E69F00", "#56B4E9", "#D55E00", "#009E73", "#0072B2", "#1ABC9C"))
ggsave(graph, file = "hash-function-benchmark.pdf", width = 10, height = 5)
