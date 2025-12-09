import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Mic, Zap, Smile, Book, Music, Lock, MessageCircle, BarChart2, Gamepad2 } from 'lucide-react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

const Tile = ({ icon: Icon, title, color, onClick }) => (
    <motion.div
        whileHover={{ scale: 1.05, rotate: 1 }}
        whileTap={{ scale: 0.95 }}
        onClick={onClick}
        className={`glass p-4 md:p-6 rounded-2xl cursor-pointer flex flex-col items-center justify-center gap-4 hover:bg-white/5 transition-all w-full aspect-square`}
    >
        <div className={`p-4 rounded-full bg-gradient-to-tr ${color} shadow-lg`}>
            <Icon size={24} className="text-white" />
        </div>
        <span className="font-medium text-gray-200">{title}</span>
    </motion.div>
);

export default function Dashboard() {
    const navigate = useNavigate();
    const [moodText, setMoodText] = useState('');
    const [loading, setLoading] = useState(false);
    const [suggestion, setSuggestion] = useState(null);

    const handleDetect = async () => {
        if (!moodText) return;
        setLoading(true);
        try {
            // 1. Detect Mood
            const moodRes = await axios.post('http://localhost:8000/api/v1/mood/detect', { text: moodText });
            const { mood, intensity } = moodRes.data;

            // 2. Get Plan
            const suggestRes = await axios.post('http://localhost:8000/api/v1/suggest', {
                mood,
                time_available_minutes: 60
            });
            setSuggestion({ mood, plan: suggestRes.data.plan });
        } catch (e) {
            console.error(e);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="p-4 md:p-8 max-w-7xl mx-auto space-y-12 pb-24">
            {/* Header */}
            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold">Hello, Friend</h1>
                <div onClick={() => { localStorage.clear(); navigate('/login') }} className="cursor-pointer h-10 w-10 rounded-full bg-gradient-to-r from-primary to-accent flex items-center justify-center font-bold">U</div>
            </div>

            {/* Mood Input Section */}
            <section className="glass-card mb-12 relative overflow-hidden">
                <div className="relative z-10 flex flex-col items-center gap-6 py-8">
                    <h2 className="text-2xl font-light text-center">How are you feeling right now?</h2>
                    <div className="w-full max-w-2xl relative">
                        <textarea
                            value={moodText}
                            onChange={(e) => setMoodText(e.target.value)}
                            placeholder="I'm feeling a bit bored and tired..."
                            className="input-field h-32 text-lg resize-none pr-12"
                        />
                        <button className="absolute bottom-4 right-4 p-2 rounded-full bg-white/10 hover:bg-white/20 transition-colors">
                            <Mic size={20} />
                        </button>
                    </div>
                    <div className="flex gap-4">
                        <button
                            onClick={handleDetect}
                            disabled={loading}
                            className="btn-primary flex items-center gap-2 px-8 py-3 text-lg"
                        >
                            {loading ? <Zap className="animate-spin" /> : <Zap />}
                            {loading ? "Analyzing..." : "Fix My Mood"}
                        </button>
                    </div>
                </div>
            </section>

            {/* Results Section */}
            <AnimatePresence>
                {suggestion && (
                    <motion.section
                        initial={{ opacity: 0, height: 0, y: 20 }}
                        animate={{ opacity: 1, height: 'auto', y: 0 }}
                        exit={{ opacity: 0, height: 0 }}
                        className="glass-card border-none bg-gradient-to-b from-primary/10 to-transparent p-6 mb-12"
                    >
                        <h3 className="text-2xl font-bold mb-6 flex items-center gap-2">
                            Detected Mood: <span className="text-accent capitalize">{suggestion.mood}</span>
                        </h3>
                        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-4">
                            {suggestion.plan.map((item, i) => (
                                <div key={i} className="bg-white/5 p-4 rounded-xl border border-white/10 hover:bg-white/10 transition-colors">
                                    <div className="text-xs text-accent uppercase tracking-widest mb-2 font-bold">{item.type}</div>
                                    <div className="font-medium text-lg leading-snug mb-4">{item.description}</div>
                                    <div className="text-sm text-gray-500 flex items-center gap-1">
                                        <Zap size={14} /> {item.time_minutes} min
                                    </div>
                                </div>
                            ))}
                        </div>
                    </motion.section>
                )}
            </AnimatePresence>

            {/* Tiles Grid */}
            <section className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-4 gap-4 md:gap-6">
                <Tile icon={Gamepad2} title="Games" color="from-yellow-400 to-orange-500" onClick={() => navigate('/games')} />
                <Tile icon={Music} title="Music" color="from-green-400 to-emerald-500" onClick={() => navigate('/music')} />
                <Tile icon={Book} title="Journal" color="from-pink-400 to-rose-500" onClick={() => navigate('/journal')} />
                <Tile icon={Lock} title="Lockbox" color="from-purple-400 to-indigo-500" onClick={() => navigate('/lockbox')} />
                <Tile icon={MessageCircle} title="AI Chat" color="from-red-400 to-pink-500" onClick={() => navigate('/chat')} />
                <Tile icon={Mic} title="Voice Mode" color="from-teal-400 to-blue-500" onClick={() => navigate('/voice')} />
                <Tile icon={BarChart2} title="History" color="from-blue-400 to-cyan-500" onClick={() => navigate('/history')} />
            </section>
        </div>
    );
}
