import exceptions._
class Balance(var amount: Double) {

// OBS: Hadde ikke trengt å legge til get / set, kunne aksessert vha. this.balance.amount 
        def set(newBalance : Double): Unit = {
            amount = newBalance
        }

        def get(): Double = {
            this.amount
        }

    }
class Account(val bank: Bank, initialBalance: Double) {

    val balance = new Balance(initialBalance)
    val uid = bank.generateAccountId

    def withdraw(amount: Double): Unit = balance.synchronized {
        if (amount > this.balance.get()) {
            throw new NoSufficientFundsException(" Not enough funds to withdraw amount.")
        } else if (amount < 0){
            throw new IllegalAmountException("Cannot withdraw a negative number. ")
        } else {
                val newBalance = this.balance.get() - amount
                this.balance.set(newBalance)
        }
    }

    def deposit(amount: Double): Unit = balance.synchronized {
        if (amount < 0){
            throw new IllegalAmountException("Cannot deposit a negative number. ")
        } else {
                val newBalance = this.balance.get() + amount
                this.balance.set(newBalance)
        }
    }

    def getBalanceAmount: Double = {
        this.balance.get()
    } 

    def transferTo(account: Account, amount: Double) = {
        bank.addTransactionToQueue(this, account, amount)
    }
}