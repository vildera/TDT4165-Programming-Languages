import akka.actor._
import exceptions._
import scala.collection.immutable.HashMap

case class TransactionRequest(toAccountNumber: String, amount: Double)

case class TransactionRequestReceipt(toAccountNumber: String,
                                     transactionId: String,
                                     transaction: Transaction)
case class BalanceRequest()



// Actor class
class Account(val accountId: String,
             val bankId: String,
             val initialBalance: Double = 0) extends Actor { // extends Actor = declearing Account as an Actor. 

    private var transactions = HashMap[String, Transaction]()


    class Balance(var amount: Double) {}

    val balance = new Balance(initialBalance)



    def getFullAddress: String = {
        bankId + accountId
    }

    def getTransactions: List[Transaction] = {
        transactions.values.toList
    }

    def allTransactionsCompleted: Boolean = {
        for (i <- transactions.values){
            if(!i.isCompleted){
                return false
            }
        }
        true
    }

    // Er det nødvendig å synkronisere her? 
    def withdraw(amount: Double): Unit = {
        if (amount < 0){
            throw new IllegalAmountException("Cannot withdraw negative amount.")
        } else if ( amount > this.balance.amount ){
            throw new NoSufficientFundsException("Not enough funds to withdraw amount.")
        } else {
            this.balance.amount -= amount 
        }
    }
    def deposit(amount: Double): Unit = {
        if (amount < 0){
            throw new IllegalAmountException("Cannot deposit negative amount.")
        } else {
            this.balance.amount += amount
        }
    }

    def getBalanceAmount: Double = {
        this.balance.amount
    }

    def sendTransactionToBank(t: Transaction): Unit = {
        val bank : ActorRef = BankManager.findBank(this.bankId)
        bank ! t
    }

    def transferTo(accountNumber: String, amount: Double): Transaction = {
        val t = new Transaction(from = getFullAddress, to = accountNumber, amount = amount)
        // checks that transaction is not already in transactions: 
        if (reserveTransaction(t)) {
            try {
                // Withdrawing unknowing if the account exists -> must therefore deposiit amount if 
                // transaction is failed -> is this the right way to do it? 
                // Fixing this when account recieved receipt (TransactionRequestReceipt)
                withdraw(amount)
                sendTransactionToBank(t)
            } catch {
                case _: NoSufficientFundsException | _: IllegalAmountException =>
                    t.status = TransactionStatus.FAILED
            }
        }
        t
    }

    def reserveTransaction(t: Transaction): Boolean = {
      if (!transactions.contains(t.id)) {
          transactions += (t.id -> t) // adding t to hashmap 
        return true
      }
      false
    }

    override def receive = {
		case IdentifyActor => sender ! this

		case TransactionRequestReceipt(to, transactionId, transaction) => {
			// Process receipt
            if (to.equals(this.getFullAddress)){
                if (this.transactions.contains(transactionId)) {
                    this.transactions.get(transactionId).get.status = transaction.status 
                    this.transactions.get(transactionId).get.receiptReceived = true
                }
                // If the transaction is FAILED we must deposit the same amount as was withdrawed in "transferTo"
                if (transaction.status == TransactionStatus.FAILED) {
                    this.deposit(transaction.amount)
                }
            }
		}

		case BalanceRequest => sender ! this.getBalanceAmount // Should return current balance

		case t: Transaction => {
			// Handle incoming transaction
            this.deposit(t.amount)
            t.status = TransactionStatus.SUCCESS
            sender ! new TransactionRequestReceipt(t.from, t.id, t)
		}
		case msg => sender ! msg
    }


}
