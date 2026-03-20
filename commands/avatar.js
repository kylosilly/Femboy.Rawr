const { EmbedBuilder } = require('discord.js');

module.exports = {
    data: {
        name: 'avatar',
        description: 'Gets a user discord pfp',
        integration_types: [0, 1],
        contexts: [0, 1, 2],
        options: [
            {
                name: 'user',
                description: 'The user to get the avatar of',
                type: 6,
                required: true
            }
        ]
    },
    async execute(interaction) {
        const user = interaction.options.getUser('user');

        if (!user) {
            return interaction.reply({ content: 'User not found', ephemeral: true });
        }

        const pfp = user.displayAvatarURL({ dynamic: true, size: 1024 });

        const embed = new EmbedBuilder()
            .setColor('#FFFFFF')
            .setTitle(`${user.displayName}'s avatar`)
            .setImage(pfp)
            .setFooter({ text: `User ID: ${user.id}` });

        await interaction.reply({ embeds: [embed] });
    }
};