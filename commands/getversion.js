const { EmbedBuilder } = require('discord.js');

module.exports = {
    data: {
        name: 'getversion',
        description: 'Gets current roblox windows version',
        integration_types: [0, 1],
        contexts: [0, 1, 2]
    },
    async execute(interaction) {
        await interaction.deferReply();

        try {
            const response = await fetch('https://whatexpsare.online/api/versions/current', {
                headers: { 'User-Agent': 'WEAO-3PService' }
            });

            if (!response.ok) {
                return interaction.editReply({ content: 'Failed to fetch current version.', ephemeral: true });
            }

            const data = await response.json();

            const embed = new EmbedBuilder()
                .setTitle('Roblox Windows Version')
                .setColor('#FFFFFF')
                .addFields(
                    {
                        name: 'Current Version:',
                        value: data.Windows,
                        inline: true
                    },
                    {
                        name: 'Last Update:',
                        value: data.WindowsDate,
                        inline: true
                    },
                    {
                        name: 'Download Link:',
                        value: `[Download](https://rdd.weao.gg/?channel=LIVE&binaryType=WindowsPlayer&version=${data.Windows})`,
                    }
                );

            await interaction.editReply({ embeds: [embed] });
        } catch (error) {
            throw error;
        }
    }
};