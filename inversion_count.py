# load contents of text file into a list
# numList
NUMLIST_FILENAME = "abc.txt"
inFile = open(NUMLIST_FILENAME, 'r')

with inFile as f:
    numList = [int(integers.strip()) for integers in f.readlines()]

count = 0


def inversionsCount(x):
    global count
    midsection = len(x) / 2
    leftArray = x[:midsection]
    rightArray = x[midsection:]
    if len(x) > 1:
        # Divid and conquer with recursive calls
        # to left and right arrays similar to
        # merge sort algorithm
        inversionsCount(leftArray)
        inversionsCount(rightArray)

        # Merge sorted sub-arrays and keep
        # count of split inversions
        i, j = 0, 0
        a = leftArray;
        b = rightArray
        for k in range(len(a) + len(b) + 1):
            if a[i] <= b[j]:
                x[k] = a[i]
                i += 1
                if i == len(a) and j != len(b):
                    while j != len(b):
                        k += 1
                        x[k] = b[j]
                        j += 1
                    break
            elif a[i] > b[j]:
                x[k] = b[j]
                count += (len(a) - i)
                j += 1
                if j == len(b) and i != len(a):
                    while i != len(a):
                        k += 1
                        x[k] = a[i]
                        i += 1
                    break
    return x


# call function and output number of inversions
inversionsCount(numList)
print(count)
