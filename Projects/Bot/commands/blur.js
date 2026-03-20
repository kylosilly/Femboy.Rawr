const { AttachmentBuilder } = require('discord.js');
const { Jimp } = require('jimp');

module.exports = {
    data: {
        name: 'blur',
        description: 'Blur an image',
        integration_types: [0, 1],
        contexts: [0, 1, 2],
        options: [
            {
                name: 'image',
                description: 'The image to blur',
                type: 11,
                required: true
            },
            {
                name: 'strength',
                description: 'The strength of the blur',
                type: 4,
                required: false
            }
        ]
    },
    async execute(interaction) {
        await interaction.deferReply();

        const attachment = interaction.options.getAttachment('image');
        const contentType = attachment.contentType;

        if (!contentType || !contentType.startsWith('image')) {
            return interaction.editReply({ content: 'Invalid image type.' });
        }

        try {
            const blurStrength = interaction.options.getInteger('strength') || 5;
            const image = await Jimp.read(attachment.proxyURL);

            image.blur(blurStrength);

            image.write('blurred.png');

            const blurred = new AttachmentBuilder('blurred.png');

            await interaction.editReply({
                files: [blurred]
            });
        } catch (error) {
            throw error;
        }
    }
};