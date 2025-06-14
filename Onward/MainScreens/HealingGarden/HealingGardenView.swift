                // Floating Talk Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingChat = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Talk")
                                    .font(.custom("Nunito", size: 16))
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color(red: 195/255, green: 177/255, blue: 225/255))
                                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                } 