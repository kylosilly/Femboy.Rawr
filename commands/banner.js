const { EmbedBuilder } = require('discord.js');

module.exports = {
    data: {
        name: 'banner',
        description: 'Gets a user banner',
        integration_types: [0, 1],
        contexts: [0, 1, 2],
        options: [
            { 
                name: 'user', 
                description: 'The user to get the banner of', 
                type: 6, 
                required: true 
            }
        ]
    },
    async execute(interaction) {
        const user = await interaction.options.getUser('user').fetch();

        if (!user) {
            await interaction.reply({ content: 'User not found', ephemeral: true });
        }

        const banner = user.bannerURL({ size: 1024 });

        if (!banner) {
            return interaction.reply({ content: 'User has no banner', ephemeral: true });
        }

        const embed = new EmbedBuilder()
            .setColor('#FFFFFF')
            .setTitle(`${user.displayName}'s banner`)
            .setImage(banner);

        await interaction.reply({ embeds: [embed] });
    }
};