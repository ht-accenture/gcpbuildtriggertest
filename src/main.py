#imports
from google.cloud import pubsub_v1


# function that will be triggered when an object is finalized
def start(event, context):
    # the message to publish, made up of information from the event
    message = \
    "An object, with the name: " + event['name'] \
    + " has been successfully uploaded to the bucket: " + event['bucket'] \
    + ".\nTime of creation: " + event['timeCreated'] \
    + "\nSize: " + event['size']\
    + "\n"
    
    # TODO fill in the following details and uncomment the lines
    project_id = "still-protocol-328412"
    topic_name = "bucket-topic"

    publisher = pubsub_v1.PublisherClient()
    topic_name = 'projects/{project_id}/topics/{topic}'.format(
        project_id=project_id, topic=topic_name)

    #publish the message to the topic
    pm = publisher.publish(topic_name, message)
    # block until message publishing is complete
    pm.result()

    return

def main():
    print('This code should not be executed as a stand-alone script.')

if __name__ == "__main__":
    main()
