import * as express from 'express';
import * as bodyParser from 'body-parser';
import * as cors from 'cors';

const app = express();

app.use(cors());
app.use(bodyParser.json());

app.get('/', function (_req: express.Request, res: express.Response) {
    res.status(200);
    res.send({
        message: "Hello world!"
    })
});
app.get('/health', function (_req: express.Request, res: express.Response) {
    res.status(200);
    res.send({
        status: 'OK'
    })
});

export default app;
