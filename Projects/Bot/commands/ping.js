module.exports = {
    data: {
        name: 'ping',
        description: 'Pong',
        integration_types: [0, 1],
        contexts: [0, 1, 2]
    },
    async execute(interaction) {
        const sent = await interaction.reply({ content: 'Ping', fetchReply: true });
        
        interaction.editReply(`Pong! ${sent.createdTimestamp - interaction.createdTimestamp}ms`);
    }
};