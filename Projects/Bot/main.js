require('dotenv').config();

const { Client, Events, GatewayIntentBits, WebhookClient, Collection, EmbedBuilder } = require('discord.js');
const CommandHandler = require('./config/CommandHandler.js');
const fs = require('fs');

const client = new Client({ 
    intents: [
        GatewayIntentBits.Guilds
    ] 
});

const webhook = new WebhookClient({
    url: process.env.WEBHOOK_URL
});

const commandFiles = fs.readdirSync('./commands').filter(file => file.endsWith('.js'));

client.commands = new Collection();
const commandsData = [];

for (const file of commandFiles) {
    const command = require(`./commands/${file}`);
    client.commands.set(command.data.name, command);
    commandsData.push(command.data);
}

function sendError(description, error) {
    const embed = new EmbedBuilder()
        .setTitle('Error 😱')
        .setColor('#FF0000')
        .setDescription(description)
        .addFields(
            {
                name: 'Error:',
                value: `\`\`\`js\n${error.message || error}\n\`\`\``
            }
        )

    webhook.send({ embeds: [embed] });
}

client.once(Events.ClientReady, async () => {
    console.log(`Bot running`);
    await CommandHandler(commandsData);
});

process.on('unhandledRejection', (error) => {
    sendError('Unhandled promise rejection', error);
});

client.on(Events.ShardError, (error) => {
    sendError('A websocket connection encountered an error', error);
});

client.on(Events.InteractionCreate, async (interaction) => {
    if (!interaction.isChatInputCommand()) {
        return;
    }

    const command = client.commands.get(interaction.commandName);

    if (!command) {
        return;
    }

    try {
        await command.execute(interaction);
    } catch (error) {
        sendError(`${interaction.user.displayName} (${interaction.user.id}) had an error while trying to run /${interaction.commandName}`, error);
        await interaction.reply({ content: 'There was an error while executing this command devs have been notified', ephemeral: true });
    }
});

client.login(process.env.BOT_TOKEN);