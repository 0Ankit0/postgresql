CREATE OR REPLACE FUNCTION notify_trigger() RETURNS trigger AS
$$
DECLARE
    payload JSON;
BEGIN
    IF TG_OP = 'INSERT' THEN
        payload := row_to_json(NEW);
    ELSIF TG_OP = 'UPDATE' THEN
        payload := row_to_json(NEW);
    END IF;

    PERFORM pg_notify('my_channel', payload::text);

    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER send_message_trigger
AFTER INSERT OR UPDATE ON messages
FOR EACH ROW
EXECUTE FUNCTION notify_trigger();

-- in the frontend we just listen to the channel 'my_channel' and whenever we receive a notification, we can update the UI accordingly.
LISTEN my_channel;