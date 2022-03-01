## Intro:

The queue itself is distributed over several amazon SQS servers to fulfill the guarantee of “At least once” delivery.


If you delete a queue, you must wait at least 60 seconds before creating a queue with the same name.

Boto3 terminology
When pulling the queue, we use `receive_message` to receive:
- MessageId
- ReceiptHandle
- Body
- MessageAttributes
- other ...

ReceiptHandle is then required by `delete_message` function to delete the message

If you provide the name of an existing queue along with the exact names and values of all the queue's attributes, CreateQueue returns the queue URL for the existing queue.

#### queue creation

We nee to provide a `QueueName` and `Attributes` 
(check [docs](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/sqs.html#SQS.Client.create_queue) for more info: )
most important Attributes (standard queue):
- DelaySeconds
- MaximumMessageSize 
- MessageRetentionPeriod: The length of time, in seconds, for which Amazon SQS retains a message ( 4 days as default)
- RedrivePolicy
- deadLetterTargetArn: The Amazon Resource Name (ARN) of the dead-letter queue to which Amazon SQS moves messages after the value of maxReceiveCount is exceeded.
- maxReceiveCount: The number of times a message is delivered to the source queue before being moved to the dead-letter queue. When the ReceiveCount for a message exceeds the maxReceiveCount for a queue, Amazon SQS moves the message to the dead-letter-queue.
- VisibilityTimeout: 

#### message creation

__Deduplication ID__ is a token used for deduplication of the sent messages. If the producer sends messages with identical content but different message attributes or messages with identical message bodies that the SQS must treat the message unique, in all these cases the producer must provide deduplication id values for the message.

In case if the SendMessage Request to the queue fails, the producer can try to resend the message to the queue as many times as possible using the same deduplication id.


If a message with the same deduplication id is sent, then the message will be received successfully but it will not be delivered until the deduplication interval expires.

Message Retention Period is the amount of time a message will remain in the queue if it is not picked by any of the processes. By default, the message retention period is 4 days. We can change the message retention period using the “SetQueueAttributes” action.

__Message Retention Period__
Message Retention Period is the amount of time a message will remain in the queue if it is not picked by any of the processes. By default, the message retention period is 4 days. We can change the message retention period using the “SetQueueAttributes” action.


__Visibility Timeout__

It is the amount of time a message is available in the queue after a reader picks up that message.

Imagine a message M in the queue is waiting to be processed. Component A sends a “Recieve message request” for message M and begins processing it. The moment component A receives that message, the visibility timeout of that message begins. The message will still be in the queue but marked as invisible. If the visibility timeout of that message is 40 seconds, during this time, even if another component B sends “Recieve Message Request “ for Message M, SQS will not deliver the message to B until the visibility timeout of the message expires.
As soon as the visibility time out of the message runs out, the message will appear back in the queue and is available for another component to pick the message and process it.

__Dead Letter Queue__
Dead Letter Queue(DLQ) is a queue of undelivered messages. It is a queue that other queues can leverage to segregate those messages that cannot be processed by consumer applications. Every message in the SQS will have a maximum receive count. If the message has not been processed by the consumer even after several retries and the maximum receive count of the message has also exceeded, then the message is sent to the Dead Letter Queue. A separate set of consumers is assigned to process the messages in a Dead Letter Queue to analyze why this set of messages failed to be processed.

## sqs monitoring 

CloudWatch metrics for your Amazon SQS queues are automatically collected and pushed to CloudWatch at one-minute intervals. These metrics are gathered on all queues that meet the CloudWatch guidelines for being active.

CloudWatch considers a queue to be active for up to six hours if it contains any messages or if any action accesses it.

### "Usefull" Available CloudWatch metrics for Amazon SQS

- ApproximateAgeOfOldestMessage
- ApproximateNumberOfMessagesDelayed : The number of messages in the queue that are delayed and not available for reading immediately. This can happen when the queue is configured as a delay queue or when a message has been sent with a delay parameter. (count)
- ApproximateNumberOfMessagesNotVisible: The number of messages that are in flight. Messages are considered to be in flight if they have been sent to a client but have not yet been deleted or have not yet reached the end of their visibility window.  For a standard SQS queue, there is a limit of 120,000 inflight messages, and and 20,000 is the limit for FIFO queues
- ApproximateNumberOfMessagesVisible: The number of messages available for retrieval from the queue.
- NumberOfEmptyReceives: The number of ReceiveMessage API calls that did not return a message.
- NumberOfMessagesDeleted: Amazon SQS emits the NumberOfMessagesDeleted metric for every successful deletion operation that uses a valid receipt handle
- NumberOfMessagesReceived
- NumberOfMessagesSent: The number of messages added to a queue.
- SentMessageSize: The size of messages added to a queue.


Note: These metrics are calculated from a service perspective, and can include retries. Don't rely on the absolute values of these metrics, or use them to estimate current queue status.

metrics that can be useful: 
* ApproximateAgeOfOldestMessage
* ApproximateNumberOfMessagesDelayed
* ApproximateNumberOfMessagesNotVisible
* NumberOfEmptyReceives
* SentMessageSize can be useful to debug weird issue
