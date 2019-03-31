import exceptions._
import scala.collection.mutable.Queue

object TransactionStatus extends Enumeration {
  val SUCCESS, PENDING, FAILED = Value
}

class TransactionQueue {
    var queue = new Queue[Transaction]
    
    // Remove and return the first element from the queue
    def pop: Transaction = queue.synchronized {
        queue.dequeue
    }

    // Return whether the queue is empty
    def isEmpty: Boolean = {
        queue.isEmpty
    }

    // Add new element to the back of the queue
    def push(t: Transaction): Unit = queue.synchronized {
        queue += t
    }

    // Return the first element from the queue without removing it
    def peek: Transaction = {
        queue.front 
    }

    // Return an iterator to allow you to iterate over the queue
    def iterator: Iterator[Transaction] = queue.synchronized{
        queue.iterator
    }
}

class Transaction(val transactionsQueue: TransactionQueue,
                  val processedTransactions: TransactionQueue,
                  val from: Account,
                  val to: Account,
                  val amount: Double,
                  val allowedAttemps: Int) extends Runnable {

  var status: TransactionStatus.Value = TransactionStatus.PENDING
  var tries: Int = allowedAttemps
  override def run: Unit = {

      def doTransaction() = {
          // en transaksjon som feiler men har flere retries igjen er fortsatt pending 
          // hvis den ikke har flere forsøk igjen er den FAILED 
            try {
                from.withdraw(amount)
                to.deposit(amount)
                this.status = TransactionStatus.SUCCESS
            } catch { 
                case e: NoSufficientFundsException => status = TransactionStatus.FAILED
                case e: IllegalAmountException => status = TransactionStatus.FAILED
            }
      }
        // to prevent deadlock 
        // låser alltid den med lavest verdi først for å ikke få deadlock
      if (from.uid < to.uid) from.synchronized {
          to.synchronized {
            doTransaction
          }
      } else to.synchronized {
          from.synchronized {
            doTransaction
          }
      }

      // Extend this method to satisfy requirements.

    }
}
