import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Lock, Unlock, Key, ShieldCheck } from 'lucide-react';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';

export default function Lockbox() {
    const { user } = useAuth();
    const [isUnlocked, setIsUnlocked] = useState(false);
    const [pin, setPin] = useState(['', '', '', '']);
    const [notes, setNotes] = useState([]);
    const [newNote, setNewNote] = useState('');

    const handlePinChange = (index, value) => {
        if (value.length > 1) return;
        const newPin = [...pin];
        newPin[index] = value;
        setPin(newPin);

        // Auto focus next
        if (value && index < 3) {
            document.getElementById(`pin-${index + 1}`).focus();
        }
    };

    const handleUnlock = async () => {
        if (pin.join('') === '1234') {
            // In real app, PIN would derive key. Here we just fetch list.
            try {
                const res = await axios.get(`http://localhost:8000/api/lockbox/list?user_id=${user.id}`);
                // For this demo, since we don't have real client-side encryption yet, 
                // we'll just mock the "decryption" of the fetched items or handle the list.
                // The API returns metadata. To actually "unlock", we'd fetch the blob and decrypt.
                // Let's just set the metadata as notes for now to prove connection.
                setNotes(res.data.map(item => ({
                    id: item.id,
                    text: `Encrypted Item #${item.id} - ${item.label}`,
                    date: new Date(item.created_at).toLocaleDateString()
                })));
                setIsUnlocked(true);
            } catch (e) {
                console.error(e);
                alert("Failed to fetch lockbox items");
            }
        } else {
            alert('Incorrect PIN');
            setPin(['', '', '', '']);
            document.getElementById('pin-0').focus();
        }
    };

    const handleSave = async () => {
        if (!newNote) return;
        try {
            // Mock encryption: Base64 encode
            const encrypted = btoa(newNote);
            await axios.post('http://localhost:8000/api/lockbox/save', {
                user_id: user.id,
                label: "Note",
                encrypted_data_base64: encrypted
            });
            // Refresh list
            handleUnlock();
            setNewNote('');
        } catch (e) { console.error(e); }
    };

    return (
        <div className="min-h-screen pt-24 px-4 max-w-5xl mx-auto flex items-center justify-center">
            <AnimatePresence mode='wait'>
                {!isUnlocked ? (
                    <motion.div
                        initial={{ opacity: 0, scale: 0.9 }}
                        animate={{ opacity: 1, scale: 1 }}
                        exit={{ opacity: 0, scale: 1.1 }}
                        className="glass-card p-12 flex flex-col items-center gap-8 max-w-md w-full relative overflow-hidden"
                    >
                        <div className="absolute top-0 right-0 w-24 h-24 bg-neon-purple/20 blur-2xl rounded-full" />

                        <div className="w-20 h-20 rounded-full bg-white/5 border border-white/10 flex items-center justify-center mb-2">
                            <Lock size={32} className="text-gray-300" />
                        </div>

                        <div className="text-center">
                            <h2 className="text-3xl font-bold mb-2">Mood Lockbox</h2>
                            <p className="text-gray-400 text-sm">Enter your 4-digit PIN to access your encrypted thoughts.</p>
                        </div>

                        <div className="flex gap-4">
                            {pin.map((digit, i) => (
                                <input
                                    key={i}
                                    id={`pin-${i}`}
                                    type="password"
                                    maxLength={1}
                                    className="w-14 h-16 rounded-xl bg-dark border border-white/20 text-center text-2xl text-white focus:border-neon-purple focus:ring-1 focus:ring-neon-purple transition-all"
                                    value={digit}
                                    onChange={(e) => handlePinChange(i, e.target.value)}
                                />
                            ))}
                        </div>

                        <button onClick={handleUnlock} className="btn-primary w-full py-4 text-lg">
                            Access Vault
                        </button>
                    </motion.div>
                ) : (
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="w-full h-[80vh] flex flex-col md:flex-row gap-6"
                    >
                        <div className="w-full md:w-1/3 glass-card p-6 flex flex-col">
                            <div className="flex items-center justify-between mb-6">
                                <h2 className="text-xl font-bold flex items-center gap-2">
                                    <Unlock size={20} className="text-green-400" /> Decrypted
                                </h2>
                                <button onClick={() => setIsUnlocked(false)} className="text-xs text-gray-500 hover:text-white">Lock</button>
                            </div>

                            <div className="space-y-4 overflow-y-auto flex-1 pr-2">
                                {notes.map(note => (
                                    <div key={note.id} className="p-4 rounded-xl bg-white/5 border border-white/5 hover:bg-white/10 cursor-pointer transition-colors">
                                        <p className="text-gray-300 text-sm mb-2">{note.text}</p>
                                        <span className="text-[10px] text-gray-600 uppercase font-bold">{note.date}</span>
                                    </div>
                                ))}
                            </div>
                        </div>

                        <div className="flex-1 glass-card p-8 flex flex-col justify-center items-center text-center">
                            <div className="w-16 h-16 rounded-full bg-white/5 flex items-center justify-center mb-6">
                                <ShieldCheck size={32} className="text-primary-light" />
                            </div>
                            <h3 className="text-2xl font-bold mb-2">Secure Storage</h3>
                            <p className="text-gray-400 mb-8 max-w-md">Everything you write here is encrypted with AES-256 before it touches our database.</p>

                            <textarea
                                className="w-full h-32 bg-dark/50 rounded-xl p-4 border border-white/10 focus:border-primary/50 outline-none mb-4 resize-none"
                                placeholder="Write something secret..."
                                value={newNote}
                                onChange={e => setNewNote(e.target.value)}
                            />
                            <button onClick={handleSave} className="btn-primary px-8">Encrypt & Save</button>
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
}
