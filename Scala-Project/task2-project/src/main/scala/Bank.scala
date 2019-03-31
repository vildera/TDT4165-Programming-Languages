import java.util.NoSuchElementException
import akka.actor._
import java.util.concurrent.atomic.AtomicInteger
import scala.concurrent.duration._
import akka.util.Timeout



case class GetAccountRequest(accountId: String)

case class CreateAccountRequest(initialBalance: Double)

case class IdentifyActor()




class Bank(val bankId: String) extends Actor {

    val accountCounter = new AtomicInteger(1000)

    def createAccount(initialBalance: Double): ActorRef = {
        // Should create a new Account Actor and return its actor reference. 
        // Accounts should be assigned with unique ids (increment with 1).
        val new_acc_id : String = accountCounter.incrementAndGet.toString
        val account : ActorRef = BankManager.createAccount(new_acc_id, bankId, initialBalance)
        account
    }

    def findAccount(accountId: String): Option[ActorRef] = {
        // Use BankManager to look up an account with ID accountId
        Some(BankManager.findAccount(bankId, accountId)) // trenger vi bankID her?
    }

    def findOtherBank(bankId: String): Option[ActorRef] = {
        // Use BankManager to look up a different bank with ID bankId
        Some(BankManager.findBank(bankId))
    }

    override def receive = {
        case CreateAccountRequest(initialBalance) => sender ! this.createAccount(initialBalance) // create new account
        case GetAccountRequest(id) => sender ! this.findAccount(id) // return account
        case IdentifyActor => sender ! this
        case t: Transaction => processTransaction(t)

        case t: TransactionRequestReceipt => 
        // Forward receipt to the right account
        val maybeAcc = this.findAccount(t.toAccountNumber)

        if (maybeAcc.isDefined){
            val acc = maybeAcc.get
            acc ! t 
        }
        case msg => sender ! msg
    }

    def processTransaction(t: Transaction): Unit = {
        implicit val timeout = new Timeout(5 seconds)
        val isInternal = t.to.length <= 4
        val toBankId = if (isInternal) bankId else t.to.substring(0, 4)
        val toAccountId = if (isInternal) t.to else t.to.substring(4)
        val transactionStatus = t.status
        
        // This method should forward Transaction t to an account or another bank, depending on the "to"-address.
        // HINT: Make use of the variables that have been defined above.

        try {
            // forwarding t to account if internal
            if (isInternal || toBankId == this.bankId){
                findAccount(toAccountId).get ! t // sett opp case istedenfor for åsjekke om  det er en account eller ikke

            // forwarding t to other bank if external
            } else {
                findOtherBank(toBankId).get ! t
            }
        } catch {
            case _: NoSuchElementException => t.status = TransactionStatus.FAILED
            // If fail: sending reciept back to A 
            sender ! new TransactionRequestReceipt(t.from, t.id, t)
        }
    }
}