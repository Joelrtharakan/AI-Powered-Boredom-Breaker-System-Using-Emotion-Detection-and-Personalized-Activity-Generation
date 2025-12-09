import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Mic, Zap, Smile, Book, Music, Lock, MessageCircle, BarChart2, Gamepad2, Sparkles, Wind, Play, Pause, SkipForward } from 'lucide-react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

const QuickActionTile = ({ icon: Icon, title, desc, onClick, delay }) => (
    <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: delay * 0.1 }}
        whileHover={{ scale: 1.05, rotateX: 5, rotateY: 5 }}
        onClick={onClick}
        className="glass-card p-6 cursor-pointer flex flex-col items-center justify-center text-center gap-4 group hover:bg-white/10"
        style={{ perspective: 1000 }}
    >
        <div className="p-4 rounded-2xl bg-white/5 group-hover:bg-primary/20 transition-colors shadow-lg shadow-black/20">
            <Icon size={28} className="text-gray-300 group-hover:text-white transition-colors" />
        </div>
        <div>
            <span className="block font-bold text-lg text-gray-200 group-hover:text-white">{title}</span>
            {desc && <span className="text-xs text-gray-500 group-hover:text-gray-400">{desc}</span>}
        </div>
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
            const moodRes = await axios.post('http://localhost:8000/api/mood/detect', { text: moodText });
            const { mood } = moodRes.data;
            const suggestRes = await axios.post('http://localhost:8000/api/suggest', {
                mood,
                time_available_minutes: 60
            });
            setSuggestion({ mood, plan: suggestRes.data.plan, intensity: moodRes.data.intensity });
        } catch (e) {
            console.error(e);
        } finally {
            setLoading(false);
        }
    };

    const handleSurprise = async () => {
        // quick stub for surprise
        const res = await axios.get('http://localhost:8000/api/surprise');
        alert(`Surprise! ${res.data.payload?.text || "Enjoy your day!"}`);
    };

    return (
        <div className="min-h-screen pb-24 px-4 pt-8 md:pt-12 max-w-7xl mx-auto space-y-16">

            {/* Header */}
            <div className="flex justify-between items-center px-2">
                <div>
                    <h1 className="text-4xl font-black title-gradient mb-1">Dashboard</h1>
                    <p className="text-gray-400">Welcome back, Traveler.</p>
                </div>
                <button onClick={() => { localStorage.clear(); navigate('/') }} className="w-12 h-12 rounded-full glass flex items-center justify-center hover:bg-white/10 transition-colors">
                    <UserAvatar />
                </button>
            </div>

            {/* A. Mood Input Section */}
            <section className="relative">
                <div className="absolute inset-0 bg-primary/5 blur-[100px] -z-10" />
                <div className="glass-card p-1 relative overflow-hidden">
                    <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-transparent via-primary to-transparent opacity-50" />
                    <div className="p-8 md:p-12 flex flex-col items-center text-center gap-8">
                        <h2 className="text-3xl md:text-5xl font-light text-white">How are you feeling?</h2>

                        <div className="w-full max-w-3xl relative group">
                            <textarea
                                value={moodText}
                                onChange={(e) => setMoodText(e.target.value)}
                                placeholder="I'm feeling a bit bored and tired..."
                                className="w-full bg-dark/50 border border-white/10 rounded-3xl p-6 md:p-8 text-xl md:text-2xl text-white placeholder-gray-600 focus:outline-none focus:border-primary/50 transition-all resize-none shadow-inner min-h-[160px]"
                            />
                            <div className="absolute bottom-6 right-6 flex gap-3">
                                <button className="p-3 rounded-full bg-white/5 hover:bg-white/10 text-white/50 hover:text-white transition-all hover:scale-110">
                                    <Mic size={24} />
                                </button>
                            </div>
                        </div>

                        <div className="flex flex-wrap gap-4 justify-center w-full">
                            <button
                                onClick={handleDetect}
                                disabled={loading}
                                className="btn-primary min-w-[200px] py-4 text-lg shadow-neon-blue/20"
                            >
                                {loading ? <Zap className="animate-spin" /> : <Sparkles />}
                                {loading ? "Analyzing..." : "Detect Mood"}
                            </button>

                            <button onClick={handleSurprise} className="btn-neon min-w-[200px] py-4 text-lg">
                                Surprise Me 🎁
                            </button>
                        </div>
                    </div>
                </div>
            </section>

            {/* B. Suggested Plan Card */}
            <AnimatePresence>
                {suggestion && (
                    <motion.section
                        initial={{ opacity: 0, scale: 0.95, y: 20 }}
                        animate={{ opacity: 1, scale: 1, y: 0 }}
                        className="glass-card border border-primary/30 p-8 md:p-10 relative overflow-hidden"
                    >
                        {/* Glow effects */}
                        <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-primary/10 rounded-full blur-[100px] -translate-y-1/2 translate-x-1/2 -z-10" />

                        <div className="mb-8 flex flex-col md:flex-row md:items-center justify-between gap-4">
                            <div>
                                <h3 className="text-sm uppercase tracking-widest text-primary-light font-bold mb-2">Analysis Complete</h3>
                                <div className="text-3xl md:text-4xl font-bold text-white capitalize flex items-center gap-3">
                                    {suggestion.mood} <span className="text-lg font-normal text-gray-500 bg-white/5 px-3 py-1 rounded-full">{Math.round((suggestion.intensity || 0) * 100)}% Intensity</span>
                                </div>
                            </div>
                            <div className="flex gap-2">
                                <button className="p-3 rounded-xl hover:bg-white/10 transition-colors"><SkipForward size={24} /></button>
                            </div>
                        </div>

                        <div className="grid md:grid-cols-4 gap-6">
                            {suggestion.plan.map((item, i) => (
                                <motion.div
                                    key={i}
                                    initial={{ opacity: 0, x: -20 }}
                                    animate={{ opacity: 1, x: 0 }}
                                    transition={{ delay: i * 0.1 }}
                                    className="bg-white/5 border border-white/5 p-6 rounded-2xl hover:bg-white/10 transition-colors flex flex-col gap-3 group"
                                >
                                    <div className="p-3 bg-dark rounded-xl w-fit group-hover:scale-110 transition-transform duration-300">
                                        <PlanIcon type={item.type} />
                                    </div>
                                    <div className="text-xs text-primary-glow font-bold uppercase tracking-wider">{item.type.replace('_', ' ')}</div>
                                    <div className="font-medium text-lg leading-snug">{item.description}</div>
                                    {item.time_minutes && <div className="mt-auto text-sm text-gray-500">{item.time_minutes} min</div>}
                                </motion.div>
                            ))}
                        </div>
                    </motion.section>
                )}
            </AnimatePresence>

            {/* C. Quick Action Tiles */}
            <section>
                <h3 className="text-2xl font-bold mb-8 flex items-center gap-3">
                    <span className="w-2 h-8 bg-primary rounded-full" />
                    Quick Actions
                </h3>
                <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
                    <QuickActionTile icon={Gamepad2} title="Mini Games" desc="Arcade Zone" onClick={() => navigate('/games')} delay={1} />
                    <QuickActionTile icon={Music} title="Music Booster" desc="Sonic Heal" onClick={() => navigate('/music')} delay={2} />
                    <QuickActionTile icon={Book} title="Journaling" desc="Mind Dump" onClick={() => navigate('/journal')} delay={3} />
                    <QuickActionTile icon={Wind} title="Breathing" desc="Visualizer" onClick={() => alert('Breathing Visualizer Overlay')} delay={4} />
                    <QuickActionTile icon={MessageCircle} title="AI Friend" desc="Chat Mode" onClick={() => navigate('/chat')} delay={5} />
                    <QuickActionTile icon={Lock} title="Mood Lockbox" desc="Secure Notes" onClick={() => navigate('/lockbox')} delay={6} />
                    <QuickActionTile icon={BarChart2} title="History" desc="Trends" onClick={() => navigate('/history')} delay={7} />
                    <QuickActionTile icon={Mic} title="Voice Mode" desc="Hands Free" onClick={() => navigate('/voice')} delay={8} />
                </div>
            </section>
        </div>
    );
}

// Subcomponents
const UserAvatar = () => (
    <div className="w-full h-full rounded-full bg-gradient-to-tr from-primary to-neon-blue p-[2px]">
        <div className="w-full h-full rounded-full bg-dark flex items-center justify-center font-bold text-sm">
            ME
        </div>
    </div>
);

const PlanIcon = ({ type }) => {
    switch (type) {
        case 'breathing': return <Wind size={20} className="text-cyan-400" />;
        case 'micro_task': return <Zap size={20} className="text-yellow-400" />;
        case 'activity': return <Sparkles size={20} className="text-purple-400" />;
        case 'music': return <Music size={20} className="text-pink-400" />;
        default: return <Smile size={20} className="text-green-400" />;
    }
}
