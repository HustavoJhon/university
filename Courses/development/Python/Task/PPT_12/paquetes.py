#1 usage
def factorial(n):
    if n==0:
        return 1
    else:
        return factorial(n-1)
#1 usage
def multiplica(num1, num2):
    if(num1==0 or num2==0):
        return 0
    else:
        if(num2==num1):
            return num1
        else:
            return num1 * multiplica(num1, num2-1)
            
