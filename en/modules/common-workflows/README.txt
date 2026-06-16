Follow these instructions each time you create a new document for the workflow you want to describe.

1. Navigate to modules/common-workflows/pages directory. 

2. Make a copy of the workflow-TEMPLATE.txt file and rename it as workflow-your-chosen-filename.adoc (note the change in extension)

3. Use full words in "your-chosen-filename", separating each word with the dash "-". 
E.g. instead of workflow-clm.adoc, use workflow-content-lifecycle-management.adoc.

4. Open newly created workflow-your-chosen-filename.adoc to start editing it.

5. Start by changing [[workflow-your-chosen-filename]] anchor.

6. Proceed by changing the page title from "Your chosen file name" to the actual title.

7. Add the content.
The instructions within the template are not strict rules, but guidelines for creating the document.
They outline main information the file should contain.

8. If you want to add reference to this new file to another topic, find the relevant topic and add the following sentence where suitable:
For more information about "Your Chosen Filename", see xref:common-workflows:workflow-your-chosen-filename.adoc[]

9. When the workflow file is ready, you need to add it to the navigation bar.
Go to o modules/common-workflows directory.
Open nav-common-workflows-guide.adoc to add the topic to the navigation bar.
Make sure you add the new topic to the navigation bar in alphabetical order.

10. Add an entry to .changelog file.

11. Submit the PR. 
Add a SME angineer and at least two members of the Doc Squad as reviewers.
If the workflow was already mentioned on the existing epic card on the Doc board, add relevant rerefence.
