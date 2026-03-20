const { REST, Routes } = require('discord.js');
const path = require('path');

require('dotenv').config();

module.exports = async (commands) => {
    const rest = new REST({ version: '10' }).setToken(process.env.BOT_TOKEN);

    try {
        if (commands.length > 0) {
            await rest.put(
                Routes.applicationCommands(process.env.CLIENT_ID),
                { body: commands }
            );
        }
    } catch (error) {
        console.error(error);
    }
};