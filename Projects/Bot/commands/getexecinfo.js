const { EmbedBuilder } = require('discord.js');

module.exports = {
    data: {
        name: 'getexecinfo',
        description: 'Get detailed information about a executor/external',
        options: [
            {
                name: 'name',
                description: 'The name of the executor/external (example: Matcha, Potassium, Wave)',
                type: 3,
                required: true
            }
        ],
        integration_types: [0, 1],
        contexts: [0, 1, 2]
    },
    async execute(interaction) {
        await interaction.deferReply();
        const executorName = interaction.options.getString('name').trim().toLowerCase();

        try {
            const response = await fetch(`https://whatexpsare.online/api/status/exploits/${executorName}`, {
                headers: { 'User-Agent': 'WEAO-3PService' }
            });

            if (!response.ok) {
                return interaction.editReply({ content: 'Failed to fetch executor info', ephemeral: true });
            }

            const json = await response.json();

            if (!json || !json.title) {
                return interaction.editReply({ content: `${executorName} data not found`, ephemeral: true });
            }

            const embed = new EmbedBuilder()
                .setTitle(`${json.title} ${json.version}`)
                .setURL(json.websitelink || null)
                .setColor('#FFFFFF')
                .setFooter({ text: 'Info gotten from https://whatexpsare.online' });

            const field = [
                {
                    name: 'Detected?',
                    value: json.detected ? 'VERY DETECTED' : 'No',
                    inline: true
                },
                {
                    name: 'Free?',
                    value: json.free ? 'Yes' : `No it costs ${json.cost}`,
                    inline: true
                },
                {
                    name: 'In Beta?',
                    value: json.beta ? 'Yes' : 'No',
                    inline: true
                },
                {
                    name: 'Updated?',
                    value: json.updateStatus ? 'Yes' : 'No',
                    inline: true
                },
                {
                    name: 'Is External?',
                    value: json.extype === 'wexternal' ? 'Yes' : 'No',
                    inline: true
                },
            ];

            if (json.suncPercentage) {
                field.push({
                    name: 'SUNC %:',
                    value: `${json.suncPercentage}%`,
                    inline: true
                });
            }

            if (json.uncPercentage) {
                field.push({
                    name: 'UNC %:',
                    value: `${json.uncPercentage}%`,
                    inline: true
                });
            }

            embed.addFields(field);

            await interaction.editReply({ embeds: [embed] });

        } catch (error) {
            throw error;
        }
    }
};