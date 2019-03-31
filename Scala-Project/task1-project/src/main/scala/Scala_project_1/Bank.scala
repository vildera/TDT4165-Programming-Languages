import scala.concurrent.forkjoin.ForkJoinPool
import scala.concurrent.ExecutionContext 
import scala.concurrent._

class Bank(val allowedAttempts: Integer = 3) {
    private var idCounter: Int = 0


    private val uid = 1
    private val transactionsQueue: TransactionQueue = new TransactionQueue()
    private val processedTransactions: TransactionQueue = new TransactionQueue()

    // Skal kunne gjenbruke threads. Oppretter threads og bruker de om igjen i executionContext 
    // setter antall tråder. Må ha flere tråder for å kjøre transactions parallelt 
    // Kunne startet en ny tråd for hver gang, men det tar mye tid uten at vi får noe igjen 
    private val threadPool = new ForkJoinPool(4) // oppretter 4 threads
    private val executionContext = ExecutionContext.fromExecutorService(threadPool)

    def addTransactionToQueue(from: Account, to: Account, amount: Double): Unit = {
      transactionsQueue.push(new Transaction(
        transactionsQueue, processedTransactions, from, to, amount, allowedAttempts))
        executionContext.submit(new Runnable {
            override def run(){
                processTransactions
            }
        })
    }

    // Kunne brukt atomic integer her
    // Hint: use a counter 
    // Må synkronisere tilfelle man prøver å generere accountID samtidig (skal ikke være mulig) 
    def generateAccountId: Int = this.synchronized {
        idCounter += 1
        idCounter
    }


    private def processTransactions: Unit = {
        // vil gi en transaction til executionContext
        // gjenbruker de 4 tråder
        // må gå i transqueue og ta det som ligger der 
        // sjekke SUCCESS eller FAILED skal uansett legge den i processed 
        //val transIterator = transactionsQueue.iterator
        // kan bruke sransactionQueue wait and notify (låser på queue og bruker notify)
            try{
                val transaction: Transaction = transactionsQueue.pop
                // kan submitte transaction uten å override run, 
                // fordi dette er allerede gjort i klassen Transaction
                executionContext.submit(transaction) // kjører transaksjonen
                while (true) {
                    while(transaction.status == TransactionStatus.PENDING){
                        Thread.sleep(100)
                    }
                    if (transaction.status == TransactionStatus.SUCCESS){
                        processedTransactions.push(transaction)
                        return
                    }
                    else if(transaction.status == TransactionStatus.FAILED){
                        if (transaction.tries > 0){
                            transaction.status = TransactionStatus.PENDING
                            transaction.tries -= 1
                            executionContext.submit(transaction)
                        }else {
                            processedTransactions.push(transaction)
                            return
                        }
                    }
                }
            } catch {
                case e: Exception => {}
            }

        
    }

    def addAccount(initialBalance: Double): Account = {
        new Account(this, initialBalance)
    }

    def getProcessedTransactionsAsList: List[Transaction] = {
        processedTransactions.iterator.toList
    }

}
