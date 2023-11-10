library(UpSetR)
library(ComplexUpset)
library(stringr)
library(ggplot2)
library(dplyr)
library(tidyr)

roommate_data <- read.csv("/Users/suleymanov-ef/Desktop/Additional education/Bioinformatics Institute/Bioinformatics/BioPracticum/Project2_test/roommate.csv", sep = " ")
SRR1705858 <- read.csv("/Users/suleymanov-ef/Desktop/Additional education/Bioinformatics Institute/Bioinformatics/BioPracticum/Project2_test/SRR1705858.csv", sep = " ")
SRR1705859 <- read.csv("/Users/suleymanov-ef/Desktop/Additional education/Bioinformatics Institute/Bioinformatics/BioPracticum/Project2_test/SRR1705859.csv", sep = " ")
SRR1705860 <- read.csv("/Users/suleymanov-ef/Desktop/Additional education/Bioinformatics Institute/Bioinformatics/BioPracticum/Project2_test/SRR1705860.csv", sep = " ")

roommate_mut <- roommate_data %>%
  mutate(Percent = read.table(text = Sample1, sep = ":", as.is = TRUE)$V7) %>%
  mutate(Rate = str_sub(Percent, 1, -2)) %>%
  select(!c(Sample1, Percent)) %>%
  mutate(Rate = as.numeric(Rate)) %>%
  mutate(SRR_ID = 'Roommate') %>%
  filter()

SRR1705858_mut <- SRR1705858 %>%
  mutate(Percent = read.table(text = Sample1, sep = ":", as.is = TRUE)$V7) %>%
  mutate(Rate = str_sub(Percent, 1, -2)) %>%
  select(!c(Sample1, Percent)) %>%
  mutate(Rate = as.numeric(Rate)) %>%
  mutate(SRR_ID = 'SRR1705858')
     
SRR1705859_mut <- SRR1705859 %>%
  mutate(Percent = read.table(text = Sample1, sep = ":", as.is = TRUE)$V7) %>%
  mutate(Rate = str_sub(Percent, 1, -2)) %>%
  select(!c(Sample1, Percent)) %>%
  mutate(Rate = as.numeric(Rate)) %>%
  mutate(SRR_ID = 'SRR1705859')

SRR1705860_mut <- SRR1705860 %>%
  mutate(Percent = read.table(text = Sample1, sep = ":", as.is = TRUE)$V7) %>%
  mutate(Rate = str_sub(Percent, 1, -2)) %>%
  select(!c(Sample1, Percent)) %>%
  mutate(Rate = as.numeric(Rate)) %>%
  mutate(SRR_ID = 'SRR1705860')
        
dataset <- bind_rows(SRR1705858_mut, SRR1705859_mut, SRR1705860_mut, roommate_mut)

ggplot(dataset, aes(x = SRR_ID, y = Rate, fill = SRR_ID)) +
  geom_boxplot()

SRR1705858_mean <- mean(SRR1705858_mut$Rate)
SRR1705859_mean <- mean(SRR1705859_mut$Rate)
SRR1705860_mean <- mean(SRR1705860_mut$Rate)
SRR1705858_sd <- sd(SRR1705858_mut$Rate)
SRR1705859_sd <- sd(SRR1705859_mut$Rate)
SRR1705860_sd <- sd(SRR1705860_mut$Rate)

mean_stats <- data.frame(
  name=c('SRR1705858', 'SRR1705859', 'SRR1705860'),
  Rate=c(SRR1705858_mean, SRR1705859_mean, SRR1705860_mean),
  sd=c(SRR1705858_sd, SRR1705859_sd, SRR1705860_sd)
)

ggplot(mean_stats) +
  geom_bar(aes(x = name, y = Rate, fill = name), stat="identity", 
                fill="skyblue", alpha=0.7) +
  geom_errorbar(aes(x=name, y=Rate, ymin = Rate - sd, ymax = Rate + sd), 
                width=0.4, colour="orange", alpha=0.9, size=1.3) +
  geom_errorbar(aes(x=name, y=Rate, ymin = Rate - 3*sd, ymax = Rate + 3*sd), 
                width=0.4, colour="darkgreen", alpha=0.9, size=1.3) +
  #geom_point(data = roommate_mut, aes(x = Rate, y = )) 
  geom_point(roommate_mut, 
             mapping = aes(x = 2, y = Rate, size = Rate, colour = Rate), 
             position = 'jitter') +
  theme_bw() +
  geom_hline(yintercept = 0.5, color = 'darkmagenta', 
             linetype = 'dashed', size = 1.5)

ggsave('/Users/suleymanov-ef/Desktop/Additional education/Bioinformatics Institute/Bioinformatics/BioPracticum/Project2_test/SNP_distribution.tiff', dpi = 600)

dataset_upset <- dataset %>%
  select(c(POS, SRR_ID)) %>%
  mutate(Count = 1) %>%
  pivot_wider(names_from = POS, values_from = Count) %>%
  replace(is.na(.), 0)

positions <- colnames(dataset_upset)[2:86]

dataset_upset[positions] = dataset_upset[positions] == 1

upset_matrix <- dataset_upset %>%
  tibble::column_to_rownames(var="SRR_ID") %>%
  t() %>%
  as.data.frame()

SRR <- colnames(upset_matrix)

intersection_plot <- upset(upset_matrix, SRR, name = "Intersection", width_ratio=0.1)

tiff("/Users/suleymanov-ef/Desktop/Additional education/Bioinformatics Institute/Bioinformatics/BioPracticum/Project2_test/Intersection_plot_full.tiff", width = 7, height = 4, units = 'in', res = 360, compression = 'none')
intersection_plot
dev.off()
  

### Bubble gum plot

dataset_bubble <- dataset %>%
  select(c(POS, SRR_ID)) %>%
  mutate(Count = 1) %>%
  pivot_wider(names_from = POS, values_from = Count) %>%
  replace(is.na(.), 0) %>%
  pivot_longer(cols = !'SRR_ID')

bubble_plot <- ggplot(dataset_bubble, aes(x = SRR_ID, y = name, fill = value, size = value)) +
  geom_point(alpha = 0.8, shape = 21, stroke = 0) +
  #geom_hline(yintercept = seq(.5, 4.5, 1), size = .2) +
  scale_x_discrete(position = "bottom") +
  scale_radius(range = c(0, 6), breaks = c(0, 1), labels = c(0, 1), limits = c(0, 1)) +
  scale_fill_gradient(low = "orange", high = "darkmagenta", breaks = c(0, 1), labels = c("No", "Yes"), limits = c(0, 1)) +
  theme_bw() +
  theme(legend.position = "bottom", 
        panel.grid.major = element_blank(),
        legend.text = element_text(size = 10, family="Arial"),
        legend.title = element_text(size = 10, family="Arial"),
        panel.border = element_rect(colour = "black", fill = NA, size = 0.5),
        axis.text = element_text(size = 10, family = "Arial"), axis.text.x=element_text(angle = 45, hjust = 0.9)) +
  guides(size = guide_legend(override.aes = list(fill = "grey", alpha = 0.5, color = "black", 
                                                 stroke = .25), label.position = "bottom",title.position = "top", 
                             order = 1), fill = guide_colorbar(ticks.colour = NA, title.position = "top", order = 2)) +
  labs(size = "Mutation: Yes/No", fill = "Mutation: Yes/No", x = NULL, y = NULL) 
  
bubble_plot

ggsave("/Users/suleymanov-ef/Desktop/Additional education/Bioinformatics Institute/Bioinformatics/BioPracticum/Project2_test/Bubble_plot_full.jpeg", 
       dpi = 600,
       width = 6,
       height = 20)
