def facotorial(n):
    if n == 0:
        return 1
    else:
        return n*facotorial(n-1)
    
def multiplica(num1, num2):
    if(num1==0  or num2==0):
        return 0
    else:
        if(num2==1):
            return num1
        else:
            return num1 + multiplica(num1, num2-1)
        
def potencia(base, exponente):
    if(exponente==0):
        return 1
    else:
        return base * potencia(base, exponente-1)
