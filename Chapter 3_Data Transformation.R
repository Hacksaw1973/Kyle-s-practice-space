
#SATURDAY NIGHT IS THE LONELIEST NIGHT OF THE WEEK

library(tidyverse)
library(nycflights13)


nycflights13::airlines

airlines

flights

planes

weather

view(flights)
print(flights, width = Inf)

glimpse(flights)

# dplyr BASICS

# The first argument in all the following functions will be the name of a data frame.
# The arguments that follow it refer to columns by their names, typed WITHOUT quotations)
# we always create a new object for our results and it is ALWAYS a data frame

# ONE FUNCTION PER ROW
# Remember that problem with creating key connections between one airlines value (faa)
# and two values from flights ('origin' and 'dest')?

# well, the solution was to simply REPEAT the function to rename ON THE NEXT LINE

# That said, the way you link lines of code is with the "pipe", represented by either "%>%" or the newer '|>". 

# The pipe " x |> f(y)" is R's way of expressing the more familiar "f(x,y)".
# In the same way, "x |> f(y) |> g(z)", which passes "x" through two functions, is the R way of coding for "g(f(x, y), z)".

# So...

flights %>%
  filter(dest == "IAH") %>%
  group_by(year, month, day) %>%
  summarize(arr_delay = mean(arr_delay, na.rm = TRUE))


# dplyr's VERBS

# Four Groups, based on what they operate on

# Group I. rows
# Group II. columns
# Group III. groups
# Group IV. tables

# GROUP I: ROWS
#   filter()
#       tells R which rows to keep based on which values you want for any given column(s)
#       first argument, as stated above, is the name of the data frame 
#       following argument(s) are the conditions that must be T\true for the row to be kept

# flights more than two hours late departing...
flights %>%
  filter(dep_delay > 120)


# flights on January 1...
# (month AND day)
flights %>%
  filter(month == 1 & day == 1)


# flights that departed either January OR February...
# (either/or)
flights %>%
  filter(month == 1 | month == 2)


# but you can use "%in%" to write that differently...
flights %>%
  filter(month %in% c(1, 2))

# to save any of these new data frames, y'all need to create an object
# and assign ( "<-" )the output of the filter to it...

jan1 <- flights %>%
  filter(month == 1, day == 1)
jan1


#   arrange()
#       THIS IS R's SORT 
#       tells R to change the order of the rows based on the column values 
#       you tell R you want to see put in order.
#       arrange() sorts in ascending value for the given column, by default (small-to-big).
#       use "desc()" inside of "arrange()" to start the sort and list first the row 
#       with the greatest value for the specified column (big-to-small). 
#       
flights %>%
arrange(desc(arr_delay))

# On its own, arrange() only sorts. The number of rows in your output will equal the number in the original data frame.
# filter() takes rows out, that is, if any of them contain the value(s) you specified in the column(s).


#    distinct()
#        finds all unique rows in a data frame. 
#        this is R's REMOVE DUPLICATES
#        and can give you, say, all DISTINCT (unique) pairings of two values...  
#
flights %>%
  distinct(origin, dest)

# ...which'll only print the unique pairs only in terms of those two columns.
# to keep all the other columns as well, use " .keep_all = TRUE "...

flights %>%
  distinct(origin, dest, .keep_all = TRUE)

# This is handy if the reason you want to narrow the dataframe down based on those variables you chose 
# is in order to do other things with the other data associated to them.

#      count()
#          But let's say you want frequencies. Let's say you want to see how many rows comport to any 
#          given pairing. For that, use count() and the " sort = TRUE " argument, like so ...

flights %>%
  count(origin, dest, sort = TRUE)

# ...and remember that, because you specified it, the rows'll be sorted and therefore in descending order.

# GROUP II: COLUMNS

# mutate() 
#    creates new columns (to the far right) derived from existing columns for calculations like means and averages and sums
# select()
#    changes which columns are present
# rename()
#    changes names of columns
# relocate()
#    changes positions of columns


#   mutate()

flights %>%
  mutate(gain = dep_delay - arr_delay, speed = distance / air_time * 60)

# use " .before " to put the new columns 'mutate' generates to the far left so that you can see them! 

flights %>%
  mutate(gain = dep_delay - arr_delay, speed = distance / air_time * 60, .before = 1)

# or set " .before " ( or " .after ") to equal one of the columns to plop 'gain' and 'speed' someplace else...

flights %>%
  mutate(gain = dep_delay - arr_delay, speed = distance / air_time * 60, .before = dep_time)


flights %>%
  mutate(gain = dep_delay - arr_delay, speed = distance / air_time * 60, .after = arr_delay)

# Remember " .keep "?

flights %>%
  mutate(gain = dep_delay - arr_delay, speed = distance / air_time * 60, .keep = "used")


# setting " .keep" to "used" calls the columns you created and any columns involved in their calculations.
# Other settings for " .keep " are  "all", "unused", or "none", not "gain".

gain_speed <- flights %>%
  mutate(gain = dep_delay - arr_delay, speed = distance / air_time * 60, .keep = "used")
view(gain_speed)

#  select()
#     "rapidly zoom in on a useful subset using operations based on the names of the variables"

flights %>%
  select(year, month, day)

# for a range of consecutive columns, use a " : "....

flights %>%
  select(carrier:dest)

# for all the columns OUTSIDE of an INCLUSIVE SET OF CONSECUTIVE COLUMNS, use a " ! " (or the less popular " - ") before the first variable...

flights %>%
  select(!carrier:dest)

flights %>%
  select(-carrier:dest)

# select columns by data type...

flights %>%
  select(where(is.character))

# tell select to give you columns where names begin or end with a specific sequence of letters...

flights %>%
  select(starts_with("arr"))

flights %>%
  select(ends_with("delay"))
  
flights %>%
  select(contains("ay"))

# select() also has an nner function for numbers...

# flights %>%
#   select(num_range("x", 1:3))


# On e way to rename columns is to set them as you go in a select function...
flights %>%
  select(tail_number = tailnum)

#...but another way is with the "rename()" function! 

#  rename()
#      this'll rename only the variables (column names) you define.

flights %>%
  rename(tail_number = tailnum)

#  relocate()
#       move variables around. Unless you specify, the function's default is move what you declare to the front...

# By default...

flights %>%
  relocate(time_hour, air_time)
#       
# and telling R to put them somewhere else...

flights %>%
  relocate(year:dep_time, .after = time_hour)

# or

flights %>%
  relocate(starts_with("arr"), .before = dep_time)

# THE PIPE

# combine a bunch with it!!!

flights %>%
  filter(dest == "IAH") %>%
  mutate(speed = distance / air_time * 60) %>%
  select(year:day, dep_time, dest, carrier, flight, speed) %>%
  arrange(desc(speed))
    
