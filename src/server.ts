import app from './app';

init().then();

async function init(): Promise<void> {
    try {
        const port = 3000;

        app.listen(port, '0.0.0.0', () => {
            console.log(`🚀 Server started: http://localhost:${port}`);
        });
    } catch (error) {
        console.error(`An error occurred: ${JSON.stringify(error)}`);
        process.exit(1);
    }
}
