@isTest
public class QuoteEmailHandlerTest {
    @isTest
    public static void testSendQuotePDFToContact() {
        // Step 1: Create the necessary records for the test (Account, Contact, Opportunity, and Quote)
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'testcontact@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = testAccount.Id,
            Contact__c = testContact.Id
        );
        insert testOpportunity;

        Quote testQuote = new Quote(
            Name = 'Test Quote',
            OpportunityId = testOpportunity.Id
        );
        insert testQuote;

        // Step 2: Create the ContentVersion (this is the actual file)
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Quote Document',
            PathOnClient = 'TestQuote.pdf',
            VersionData = Blob.valueOf('PDF content here'),
            IsMajorVersion = true
        );
        insert contentVersion;

        // Step 3: Query the ContentDocument created from the ContentVersion insert
        ContentDocument contentDoc = [
            SELECT Id 
            FROM ContentDocument 
            WHERE Id = :contentVersion.ContentDocumentId 
            LIMIT 1
        ];

        // Step 4: Create ContentDocumentLink between Quote and ContentDocument
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = testQuote.Id,
            ContentDocumentId = contentDoc.Id,
            ShareType = 'V'
        );
        insert contentDocumentLink;

        // Step 5: Start the test execution context
        Test.startTest();

        // Step 6: Call the method to send the quote email
        List<Id> quoteIds = new List<Id>{testQuote.Id};
        QuoteEmailHandler.sendQuotePDFToContact(quoteIds);

        Test.stopTest();
        
        // Step 7: Verify email sending (optional, depending on your setup)
        // You can use 'Test.getSentEmailMessages()' to verify if the email was sent
    }
}
