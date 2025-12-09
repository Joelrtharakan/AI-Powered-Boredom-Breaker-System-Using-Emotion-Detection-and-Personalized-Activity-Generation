import { motion } from 'framer-motion';

const GameCard = ({ title, description, color }) => (
    <motion.div
        whileHover={{ scale: 1.02 }}
        className="glass-card p-8 flex flex-col items-center text-center gap-4 cursor-pointer"
    >
        <div className={`w-16 h-16 rounded-2xl bg-gradient-to-tr ${color} mb-2`} />
        <h3 className="text-2xl font-bold">{title}</h3>
        <p className="text-gray-400">{description}</p>
        <button className="btn-primary mt-4">Play Now</button>
    </motion.div>
);

export default function Games() {
    return (
        <div className="p-8 max-w-7xl mx-auto min-h-screen">
            <div className="mb-12">
                <h1 className="text-4xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-yellow-400 to-orange-500 mb-2">Arcade Zone</h1>
                <p className="text-gray-300">Boost your dopamine with these quick games.</p>
            </div>

            <div className="grid md:grid-cols-3 gap-8">
                <GameCard
                    title="Reaction Time"
                    description="Test your visual reflexes. Click when it turns green."
                    color="from-red-500 to-orange-500"
                />
                <GameCard
                    title="Number Guess"
                    description="Guess the number between 1 and 100."
                    color="from-blue-500 to-cyan-500"
                />
                <GameCard
                    title="Memory Flip"
                    description="Find the matching pairs."
                    color="from-purple-500 to-pink-500"
                />
            </div>
        </div>
    )
}
